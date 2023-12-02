param(
    [Parameter(Mandatory=$true)]
    [int[]]$EventIDs
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




function CreateLoggingScriptForEventIDs {
    param($EventIDs)

    $auditSetting = "auditpol /clear"

    # Загрузка данных из файла event_categories.json
    $configPath = "C:\Users\niklo\coursework\event_categories.json"
    $eventCategories = Get-Content -Path $configPath | ConvertFrom-Json

    $EventIDs | ForEach-Object {
        $eventID = $_
        # Поиск соответствующей категории по EventID из конфигурационного файла
        $category = ($eventCategories.EventCategories | Where-Object { $_.EventID -eq $eventID }).Category

        # Создание строки настройки логирования
        if ($category) {
            $auditSetting += "; auditpol /set /subcategory:'$eventID' /category:'$category' /success:enable /failure:enable"
        } else {
            Write-Host "Event ID $eventID не имеет соответствующей категории в конфигурационном файле."
        }
    }
    return $auditSetting
}

$loggingScript = CreateLoggingScriptForEventIDs -EventIDs $EventIDs
Write-ColorText "Скрипт для настройки логирования EventIDs:" "Yellow"
Write-Output $loggingScript


   $applyScriptPrompt = Read-Host "Хотите запустить скрипт настройки логирования на тестовой машине? (да/нет)"
if ($applyScriptPrompt -eq "да") {
    $targetHostname = Read-Host "Введите адрес тестовой машины"
    Write-ColorText "Применение настроек логирования на хост $targetHostname" "Yellow"
    Write-ColorText "Настройки успешно применены на машине $targetHostname" "Green"
} else {
    Pause
}




    $collectEventsPrompt = Read-Host "Хотите собрать события с тестовой машины? (да/нет)"
    if ($collectEventsPrompt -eq "да") {
        $targetHostname = Read-Host "Введите адрес тестовой машины"
        Write-ColorText "Сбор событий с хоста $targetHostname" "Yellow"
        # Код для сбора событий с целевого хоста и сохранения в CSV
        $events = Get-WinEvent -LogName Security -MaxEvents 100 |
    Select-Object -Property TimeCreated, Id, Message
       $events | Export-Csv -Path "CollectedEvents.csv" -Encoding UTF8 -NoTypeInformation

        Write-ColorText "События успешно собраны и сохранены в CollectedEvents.csv" "Green"
    }

Read-Host "Нажмите Enter для завершения программы"
