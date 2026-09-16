param(
    [string]$QuestaBin = 'C:\altera_lite\25.1std\questa_fse\win64',
    [ValidateSet('Basic','Hazard','Control','Memory','X0','Reference')][string]$Suite = 'Basic',
    [switch]$Reference,
    [string]$PythonExe = 'python'
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$useReference = $Reference -or $Suite -in @('Memory','X0','Reference')
if ($useReference -and !(Get-Command $PythonExe -ErrorAction SilentlyContinue)) {
    throw "Python not found: $PythonExe (specify -PythonExe)"
}
$outputDir = Join-Path $repo ("build/{0}_regression_cli" -f $Suite.ToLower())
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
$vsim = Join-Path $QuestaBin 'vsim.exe'
$vlog = Join-Path $QuestaBin 'vlog.exe'
$vlib = Join-Path $QuestaBin 'vlib.exe'
foreach ($tool in @($vsim, $vlog, $vlib)) {
    if (!(Test-Path -LiteralPath $tool)) { throw "Tool not found: $tool" }
}
Push-Location $outputDir
try {
    if (!(Test-Path -LiteralPath 'work')) {
        & $vlib work
        if ($LASTEXITCODE -ne 0) { throw 'vlib failed' }
    }
    $sources = @((Join-Path $repo 'rtl/utils/gen_dff.v'))
    foreach ($name in @('pc_reg','if_id','id','id_ex','ex','ex_mem','forwarding','mem','mem_wb','wb','regs','ctrl','orion_rv','hazard_detection')) {
        $sources += Join-Path $repo "rtl/core/$name.v"
    }
    $sources += Join-Path $repo 'tb/orion_rv_core_tb.v'
    & $vlog -work work "+incdir+$repo/rtl/core" @sources *> compile.log
    if ($LASTEXITCODE -ne 0) { throw "Compile failed; see $outputDir/compile.log" }
    $results = @()
    $names = @('add','andi','auipc','beq','bge','bgeu','blt','bltu','bne','jal','jalr','lui','ori','simple','slli','slti','sltiu','srai','srli','xori')
    $folder = 'Baisc_Inst_Example'
    if ($Suite -eq 'Hazard') {
        $folder = 'Hazard_Example'
        $names = @('ex_mem','mem_wb','dual_sources','latest_priority','load_alu','load_branch','load_store_data','load_store_addr')
    }
    if ($Suite -eq 'Control') {
        $folder = 'Control_Hazard'
        $controlCases = Get-Content -LiteralPath (Join-Path $repo 'test_instruction/Control_Hazard/tests.json') -Raw | ConvertFrom-Json
        $names = @($controlCases | ForEach-Object { $_.name })
    }
    if ($Suite -in @('Memory','X0','Reference')) {
        $folder = @{Memory='Memory_Example'; X0='X0_Example'; Reference='Reference_Example'}[$Suite]
        $extendedCases = Get-Content -LiteralPath (Join-Path $repo "test_instruction/$folder/tests.json") -Raw | ConvertFrom-Json
        $names = @($extendedCases | ForEach-Object { $_.name })
    }
    foreach ($name in $names) {
        $program = (Join-Path $repo "test_instruction/$folder/inst_$name.data").Replace('\','/')
        $log = Join-Path $outputDir "inst_$name.log"
        if (!(Test-Path -LiteralPath $program)) { throw "Missing image: $program" }
        # -c explicitly disables the GUI. Each test starts with fresh state.
        $checks = @()
        if ($Suite -eq 'Hazard') {
            $stalls = if ($name.StartsWith('load_')) { 1 } else { 0 }
            $checks += "+EXPECT_STALLS=$stalls"
            switch ($name) {
                ex_mem { $checks += @('+CHECK_PC=16', '+CHECK_A=1', '+CHECK_B=1') }
                mem_wb { $checks += @('+CHECK_PC=20', '+CHECK_A=2', '+CHECK_B=2') }
                dual_sources { $checks += @('+CHECK_PC=20', '+CHECK_A=2', '+CHECK_B=1') }
                latest_priority { $checks += @('+CHECK_PC=20', '+CHECK_A=1', '+CHECK_B=1') }
            }
        }
        if ($Suite -eq 'Control') {
            $case = $controlCases | Where-Object { $_.name -eq $name }
            $checks += @('+CONTROL_CHECK', "+EXPECT_STALLS=$($case.stalls)",
                "+CONTROL_START=$($case.start)", "+CONTROL_END=$($case.end)",
                "+EXPECT_REDIRECTS=$($case.redirects)", "+EXPECT_NOT_TAKEN=$($case.notTaken)",
                "+EXPECT_POISON=$($case.poison)", "+EXPECT_OLDER=$($case.older)")
        }
        if ($Suite -eq 'X0') {
            $case = $extendedCases | Where-Object { $_.name -eq $name }
            $checks += @('+X0_CHECK', '+EXPECT_STALLS=0', "+EXPECT_X0_LOADS=$($case.loads)")
        }
        if ($useReference) {
            $tracePath = (Join-Path $outputDir "inst_$name.trace").Replace('\','/')
            $checks += "+TRACE=$tracePath"
        }
        # Windows PowerShell 5 treats redirected native stderr as an error record.
        # Preserve the full log and inspect exit code instead of aborting early.
        $ErrorActionPreference = 'Continue'
        & $vsim -c -onfinish exit work.orion_rv_core_tb "+PROG=$program" +NO_VCD @checks -do 'run -all; quit -f' *> $log
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = 'Stop'
        $content = Get-Content -LiteralPath $log -Raw
        $status = 'ERROR'
        if ($exitCode -eq 0 -and $content -match 'TEST_PASS:') { $status = 'PASS' }
        elseif ($content -match 'TEST_FAIL:') { $status = 'FAIL' }
        elseif ($content -match 'TEST_TIMEOUT:') { $status = 'TIMEOUT' }
        if ($useReference -and $status -eq 'PASS') {
            $refReport = Join-Path $outputDir "inst_$name.reference.json"
            & $PythonExe (Join-Path $repo 'tb/rv32i_reference.py') --program $program --trace $tracePath --report $refReport
            if ($LASTEXITCODE -ne 0) { $status = 'FAIL' }
        }
        $row = "inst_$name.data`t$status"
        $results += $row
        Write-Host $row
        $results | Set-Content -LiteralPath results.txt
        if ($content -match 'Failure to obtain.*license|Unable to checkout|Invalid host') {
            throw "Questa license error; regression stopped. See $log"
        }
    }
    $counts = foreach ($status in @('PASS','FAIL','TIMEOUT','ERROR')) {
        '{0} {1}' -f @($results | Where-Object { $_.EndsWith("`t$status") }).Count, $status
    }
    $summary = 'SUMMARY: ' + ($counts -join ', ')
    Add-Content -LiteralPath results.txt -Value $summary
    Write-Host $summary
    Write-Host "Logs and report: $outputDir"
}
finally { Pop-Location }
