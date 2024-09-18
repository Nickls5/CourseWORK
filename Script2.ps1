    param(
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

if (-not $EventIDs) {
    Write-ColorText "Отсутствуют EventIDs для обработки" "Red"
} else {
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
                        $categoryData = [PSCustomObject]@{
                            EventID = $eventID
                            Category = $currentCategory
                        }
                        if ($categoryData -notin $categories) {
                            $categories += $categoryData
                        }
                    }
                }
            }
        }

        return $categories
    }

    function Generate-AuditSettings {
        param(
            [object[]]$CategoryData
        )

        $auditSetting = "auditpol /clear"
        foreach ($category in $CategoryData) {
            $auditSetting += "; auditpol /set /subcategory:$($category.Category) /success:enable /failure:enable"
        }

        return $auditSetting
    }

    # Получение содержимого файла конфигурации
    $auditConfigFile = "C:\Users\niklo\coursework\default_audit.bat.txt"

    Write-ColorText "Добро пожаловать в программу настройки логирования" "Green"
    Write-Host -ForegroundColor DarkYellow "    __                ______            _____                        __            "
    Write-Host -ForegroundColor DarkYellow "   / /   ____  ____ _/ ____/___  ____  / __(_)_______  ____________/ /_____  _____"
    Write-Host -ForegroundColor DarkYellow "  / /   / __ \/ __  / /   / __ \/ __ \/ /_/ / __  / / / / ___/ __  / __/ __ \/ ___/"
    Write-Host -ForegroundColor DarkYellow " / /___/ /_/ / /_/ / /___/ /_/ / / / / __/ / /_/ / /_/ / /  / /_/ / /_/ /_/ / /    "
    Write-Host -ForegroundColor DarkYellow "/_____/\____/\__  /\____/\____/_/ /_/_/ /_/\__  /\____/_/   \____/\__/\____/_/     "
    Write-Host -ForegroundColor DarkYellow "            /____/                        /____/                                   "

    $categoriesToSet = @()
    foreach ($eventID in $EventIDs) {
        $categories = Get-AuditCategoryForEvent -configFile $auditConfigFile -eventID $eventID
        if ($categories) {
            foreach ($category in $categories) {
                Write-Host "Событие с ID $($category.EventID) относится к категории: $($category.Category)"

                if ($category -notin $categoriesToSet) {
                    $categoriesToSet += $category
                }
            }
        } else {
            Write-Host "Для события с ID $eventID не найдено категорий"
        }
    }

    if ($categoriesToSet.Count -eq 0) {
        Write-Host "Нет категорий для предоставленных EventIDs"
    } else {
        Write-Host "Категории, для которых будут применены настройки:"
        foreach ($category in $categoriesToSet) {
            Write-Host $category.Category
        }
    }

    $generatedSettings = Generate-AuditSettings -CategoryData $categoriesToSet
    Write-Host "Команды для настройки логгирования:"
    Write-Host $generatedSettings

    Write-ColorText "Программа успешно завершила работу" "Green"
}

Read-Host "Нажмите Enter для завершения программы"
