param(
    [Parameter(Mandatory=$true)]
    [int[]]$EventIDs,
    [switch]$ApplyLogs,
    [switch]$CollectEvents
)

function Write-ColorText {
    param(
        [string]$text,
        [string]$color
    )
    switch ($color) {
        "Green" { Write-Host $text -ForegroundColor Green }
        "Yellow" { Write-Host $text -ForegroundColor Yellow }
        "Red" { Write-Host $text -ForegroundColor Red }
        default { Write-Host $text }
    }
}

Write-ColorText "Добро пожаловать в программу настройки логирования" "Green"


Write-Host -ForegroundColor DarkYellow "    ___         __        __                      _            "
Write-Host -ForegroundColor DarkYellow "   /   | __  __/ /_____  / /   ____  ____ _____ _(_)___  ____ _"
Write-Host -ForegroundColor DarkYellow "  / /| |/ / / / __/ __ \/ /   / __ \/ __  / __  / / __ \/ __  /"
Write-Host -ForegroundColor DarkYellow " / ___ / /_/ / /_/ /_/ / /___/ /_/ / /_/ / /_/ / / / / / /_/ / "
Write-Host -ForegroundColor DarkYellow "/_/  |_\__,_/\__/\____/_____/\____/\__, /\__, /_/_/ /_/\__, /  "
Write-Host -ForegroundColor DarkYellow "                                  /____//____/        /____/   "
Write-Host -ForegroundColor DarkYellow ""



function CreateLoggingScriptForEventIDs {
    param($EventIDs)

    $auditSetting = "auditpol /clear"
    $EventIDs | ForEach-Object {
        $auditSetting += "; auditpol /set /subcategory:$_ /success:enable /failure:enable"
    }
    return $auditSetting
}

$loggingScript = CreateLoggingScriptForEventIDs -EventIDs $EventIDs
Write-ColorText "Скрипт для настройки логирования EventIDs:" "Yellow"
Write-Output $loggingScript

if ($ApplyLogs) {
   $applyScriptPrompt = Read-Host "Хотите запустить скрипт настройки логирования на тестовой машине? (да/нет)"
if ($applyScriptPrompt -eq "да") {
    $targetHostname = Read-Host "Введите адрес тестовой машины"
    Write-ColorText "Применение настроек логирования на хост $targetHostname" "Yellow"
    Write-ColorText "Настройки успешно применены на машине $targetHostname" "Green"
} else {
    Pause
}
}


if ($CollectEvents) {
    $collectEventsPrompt = Read-Host "Хотите собрать события с тестовой машины? (да/нет)"
    if ($collectEventsPrompt -eq "да") {
        $targetHostname = Read-Host "Введите адрес тестовой машины"
        Write-ColorText "Сбор событий с хоста $targetHostname" "Yellow"
        # Ваш код для сбора событий с целевого хоста и сохранения в CSV
        $events = Get-WinEvent -LogName Security -MaxEvents 100 |
    Select-Object -Property TimeCreated, Id, Message
       $events | Export-Csv -Path "CollectedEvents.csv" -Encoding UTF8 -NoTypeInformation

        Write-ColorText "События успешно собраны и сохранены в CollectedEvents.csv" "Green"
    }
}
Read-Host "Нажмите Enter для завершения программы"
