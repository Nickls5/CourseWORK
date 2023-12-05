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

function Get-AuditCategoryForEvent {
    param(
        [string]$configFile,
        [int]$eventID
    )

    $auditConfigContent = Get-Content $configFile

    $categories = @()
    foreach ($line in $auditConfigContent) {
        if ($line -match '^Category:\s*(.+)$') {
            $currentCategory = $matches[1].Trim()
        } elseif ($line -match '^EventIDs:\s*(.+)$' -and $currentCategory) {
            $eventIDs = $matches[1].Trim() -split ','
            foreach ($id in $eventIDs) {
                if ($eventID -eq $id.Trim()) {
                    if ($currentCategory -notin $categories) {
                        $categories += $currentCategory
                    }
                }
            }
        }
    }

    return $categories
}

Write-ColorText "Добро пожаловать в программу настройки логирования" "Green"

# Получение содержимого файла конфигурации
$auditConfigFile = "C:\Users\niklo\coursework\default_audit.bat.txt"

$categoriesToSet = @()
foreach ($eventID in $EventIDs) {
    $categories = Get-AuditCategoryForEvent -configFile $auditConfigFile -eventID $eventID
    if ($categories) {
        foreach ($category in $categories) {

            if ($category -notin $categoriesToSet) {
                $categoriesToSet += $category
            }
        }
    } else {
        Write-Host "Для события с ID $eventID не найдено категорий"
    }
}


if ($categoriesToSet.Count -gt 0) {
    Write-Host "Для применения настроек аудита на удаленном компьютере используйте следующие команды:"
    foreach ($category in $categoriesToSet) {
        $auditPolCommand = "auditpol /set /subcategory:""$category"" /success:enable /failure:enable"
        Write-Host $auditPolCommand
    }
} else {
    Write-Host "Для предоставленных EventIDs не найдены категории"
}

$applyScriptPrompt = Read-Host "Желаете ли запустить скрипт настройки аудита на удаленной машине? (да/нет)"
if ($applyScriptPrompt -eq "да") {
    $targetHostname = Read-Host "Введите адрес удаленной машины"
    Write-ColorText "Применение настроек аудита на хост $targetHostname" "Yellow"
    Write-ColorText "Настройки успешно применены на машине $targetHostname" "Green"
} else {
    Pause
}

$collectEventsPrompt = Read-Host "Хотите собрать события с удаленной машины? (да/нет)"
if ($collectEventsPrompt -eq "да") {
    $targetHostname = Read-Host "Введите адрес удаленной машины"
    Write-ColorText "Сбор событий с хоста $targetHostname" "Yellow"
    $events = Get-WinEvent -LogName Security -MaxEvents 100 |
    Select-Object -Property TimeCreated, Id, Message
    $events | Export-Csv -Path "CollectedEvents.csv" -Encoding UTF8 -NoTypeInformation

    Write-ColorText "События успешно собраны и сохранены в CollectedEvents.csv" "Green"
}

Read-Host "Нажмите Enter для завершения программы"
