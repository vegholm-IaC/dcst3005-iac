<#
.SYNOPSIS
    Selvtest for obligatorisk øving 1.

.DESCRIPTION
    Kontrollerer kravene K1-K12 mot repoet ditt, og mot Azure hvis du oppgir
    argumentene. Skriptet LESER bare - det endrer ingenting, verken i repoet
    eller i Azure.

    Kjør det fra rota av repoet ditt.

    Denne fila skal gi nøyaktig samme resultat som sjekk-oblig.sh. Endrer du
    den ene, endrer du den andre.

    Virker i Windows PowerShell 5.1 (den som følger med Windows) og i
    PowerShell 7. Du trenger git i PATH, og az hvis du bruker -AppId eller
    -StorageAccount.

    Får du «cannot be loaded because running scripts is disabled on this
    system», er det Windows' standardinnstilling som stopper deg - ikke noe
    galt med skriptet. Start det slik i stedet:

        powershell -ExecutionPolicy Bypass -File .\Sjekk-Oblig.ps1

    Det gjelder bare den ene kjøringen, og endrer ingen innstilling.

    Merk: skriptet kan ta feil. Mener du et AVVIK er urimelig, skriv det i
    innleveringen og forklar hvorfor - det teller ikke mot deg å være uenig
    med et skript, så lenge du begrunner det.

.PARAMETER AppId
    Client-ID til App Registration-en. Slår på Azure-kontrollene for K10.

.PARAMETER StorageAccount
    Storage account der state ligger. Slår på Azure-kontrollen for K6.

.PARAMETER Container
    Containeren i storage accounten. Standard: tfstate.

.EXAMPLE
    .\Sjekk-Oblig.ps1

.EXAMPLE
    .\Sjekk-Oblig.ps1 -AppId <app-id> -StorageAccount <konto> -Container tfstate
#>

[CmdletBinding()]
param(
    [string]$AppId = "",
    [string]$StorageAccount = "",
    [string]$Container = "tfstate"
)

$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# ---------------------------------------------------------------------------
#  Utskrift
# ---------------------------------------------------------------------------

$script:AntallOk = 0
$script:AntallAvvik = 0
$script:AntallManuell = 0
$script:AntallHoppet = 0
$script:Avviksliste = @()

function Write-Ok {
    param([string]$Krav, [string]$Tekst)
    Write-Host "  OK       " -ForegroundColor Green -NoNewline
    Write-Host ("{0,-5} {1}" -f $Krav, $Tekst)
    $script:AntallOk++
}

function Write-Avvik {
    param([string]$Krav, [string]$Tekst, [string]$Hjelp)
    Write-Host "  AVVIK    " -ForegroundColor Red -NoNewline
    Write-Host ("{0,-5} {1}" -f $Krav, $Tekst)
    Write-Host ("           -> {0}" -f $Hjelp) -ForegroundColor DarkGray
    $script:AntallAvvik++
    $script:Avviksliste += $Krav
}

function Write-Manuell {
    param([string]$Krav, [string]$Tekst, [string]$Hjelp)
    Write-Host "  MANUELL  " -ForegroundColor Yellow -NoNewline
    Write-Host ("{0,-5} {1}" -f $Krav, $Tekst)
    Write-Host ("           -> {0}" -f $Hjelp) -ForegroundColor DarkGray
    $script:AntallManuell++
}

function Write-Hoppet {
    param([string]$Krav, [string]$Tekst, [string]$Hjelp)
    Write-Host "  HOPPET   " -ForegroundColor DarkGray -NoNewline
    Write-Host ("{0,-5} {1}" -f $Krav, $Tekst)
    Write-Host ("           -> {0}" -f $Hjelp) -ForegroundColor DarkGray
    $script:AntallHoppet++
}

function Write-Bolk {
    param([string]$Tekst)
    Write-Host ""
    Write-Host $Tekst -ForegroundColor White
}

# ---------------------------------------------------------------------------
#  Hjelpere
# ---------------------------------------------------------------------------

# Sti-skillet er \ på Windows og / ellers. Vi matcher begge, slik at skriptet
# oppfører seg likt i Windows PowerShell og i PowerShell 7 på Mac og Linux.
$script:Utelat = '[\\/](\.git|\.terraform)[\\/]'

function Get-Filer {
    param([string]$Sti = ".", [string]$Filter = "*")
    if (-not (Test-Path $Sti)) { return @() }
    Get-ChildItem -Path $Sti -Recurse -File -Filter $Filter -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch $script:Utelat }
}

function Get-TfFiler { Get-Filer -Sti "." -Filter "*.tf" }

# Filer under $Sti som inneholder $Monster. Returnerer relative stier.
function Find-Monster {
    param([string]$Monster, [string]$Sti = ".", [string]$Filter = "*")
    $treff = @()
    foreach ($f in (Get-Filer -Sti $Sti -Filter $Filter)) {
        $innhold = Get-Content -Path $f.FullName -Raw -ErrorAction SilentlyContinue
        if ($null -ne $innhold -and $innhold -match $Monster) {
            $treff += (Resolve-Path -Relative $f.FullName)
        }
    }
    return $treff
}

Write-Host ""
Write-Host "Selvtest for obligatorisk øving 1" -ForegroundColor White
Write-Host ("Repo: {0}" -f (Get-Location).Path) -ForegroundColor DarkGray

if (-not (Test-Path ".git")) {
    Write-Host ""
    Write-Host "  Dette ser ikke ut som rota av et git-repo." -ForegroundColor Red
    Write-Host "  Kjør skriptet fra mappa der .git ligger."
    Write-Host ""
    exit 1
}

# ===========================================================================
#  A · KODEN
# ===========================================================================

Write-Bolk "A · Koden"

# --- K1 --------------------------------------------------------------------

$modulmapper = @()
if (Test-Path "modules") {
    $modulmapper = Get-ChildItem -Path "modules" -Directory -ErrorAction SilentlyContinue
}

if ($modulmapper.Count -eq 0) {
    Write-Avvik "K1" "Modul med main/variables/outputs" `
        "Fant ingen mappe under modules/. Kravet forutsetter modules/<navn>/"
} else {
    $k1feil = ""
    foreach ($m in $modulmapper) {
        foreach ($f in @("main.tf", "variables.tf", "outputs.tf")) {
            if (-not (Test-Path (Join-Path $m.FullName $f))) {
                $k1feil += "modules/$($m.Name)/$f mangler. "
            }
        }
        $varfil = Join-Path $m.FullName "variables.tf"
        if (Test-Path $varfil) {
            $utenDesc = @()
            $navn = ""; $inblokk = $false; $harDesc = $false
            foreach ($linje in (Get-Content $varfil)) {
                if ($linje -match '^\s*variable\s+"([^"]+)"') {
                    $navn = $Matches[1]; $inblokk = $true; $harDesc = $false; continue
                }
                if ($inblokk -and $linje -match '^\s*description\s*=') { $harDesc = $true }
                if ($inblokk -and $linje -match '^\s*\}\s*$') {
                    if (-not $harDesc) { $utenDesc += $navn }
                    $inblokk = $false
                }
            }
            if ($utenDesc.Count -gt 0) {
                $k1feil += "Uten description i modules/$($m.Name): " + ($utenDesc -join " ") + " "
            }
        }
    }
    if ($k1feil -ne "") {
        Write-Avvik "K1" "Modul med main/variables/outputs" $k1feil
    } else {
        Write-Ok "K1" "Modul med main/variables/outputs, alle variabler har description"
    }
}

if (Test-Path "stacks") {
    if ((Find-Monster -Monster 'module\s+"' -Sti "stacks").Count -gt 0) {
        Write-Ok "K1" "Modulen brukes av en stack"
    } else {
        Write-Avvik "K1" "Modulen brukes av en stack" `
            "Fant ingen module-blokk under stacks/. En ubrukt modul teller ikke"
    }
} else {
    Write-Avvik "K1" "Modulen brukes av en stack" "Fant ingen stacks/-mappe"
}

# --- K2 --------------------------------------------------------------------

if ($modulmapper.Count -gt 0) {
    $foreach = (Find-Monster -Monster 'for_each\s*=' -Sti "modules").Count
    $count = (Find-Monster -Monster '(?m)^\s*count\s*=' -Sti "modules").Count
    if ($foreach -gt 0) {
        Write-Ok "K2" "Flere like ressurser fra én blokk med for_each"
    } elseif ($count -gt 0) {
        Write-Avvik "K2" "for_each i modulen" `
            "Fant count, men ikke for_each. Kravet ber om for_each - se modul 3"
    } else {
        Write-Avvik "K2" "for_each i modulen" `
            "Fant verken for_each eller count under modules/"
    }
}

# --- K3 --------------------------------------------------------------------

if (Test-Path "stacks") {
    if ((Find-Monster -Monster 'locals\s*\{' -Sti "stacks").Count -gt 0) {
        Write-Ok "K3" "Navn bygges i locals"
    } else {
        Write-Avvik "K3" "Navn bygges i locals" `
            "Fant ingen locals-blokk under stacks/. Se modul 1, side 13-14"
    }
}

$subsTreff = @()
foreach ($f in (Get-TfFiler)) {
    $innhold = Get-Content -Path $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -ne $innhold -and $innhold -match '/subscriptions/') { $subsTreff += $f.Name }
}
if ($subsTreff.Count -eq 0) {
    Write-Ok "K3" "Ingen hardkodet /subscriptions/-ID i koden"
} else {
    Write-Avvik "K3" "Ingen hardkodet /subscriptions/-ID i koden" `
        "Fant /subscriptions/ i $($subsTreff.Count) fil(er). Bruk data-kilder eller variabler"
}

# --- K4 --------------------------------------------------------------------
#  Vi deler hvert stinavn på - _ og . og krever EKSAKT treff på et ledd, slik
#  at "stacks/dev" og "main-prod.tf" fanges, mens "producer.tf" og "latest.tf"
#  ikke gjør det. Samme regel som i bash-utgaven.

if (Test-Path "stacks") {
    $miljonavn = @()
    $alle = Get-ChildItem -Path "stacks" -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/]\.terraform[\\/]' }
    foreach ($p in $alle) {
        $ledd = $p.Name -replace '\.tf$', ''
        $ord = $ledd.ToLower() -split '[-_.]'
        foreach ($o in $ord) {
            if ($o -eq 'dev' -or $o -eq 'test' -or $o -eq 'prod') {
                $miljonavn += (Resolve-Path -Relative $p.FullName)
                break
            }
        }
    }
    if ($miljonavn.Count -eq 0) {
        Write-Ok "K4" "Én stack-definisjon - miljønavn ikke i fil- eller mappenavn"
    } else {
        $vis = ($miljonavn -join " ")
        if ($vis.Length -gt 160) { $vis = $vis.Substring(0, 160) }
        Write-Avvik "K4" "Én stack-definisjon" `
            "Miljønavn i sti: $vis - se modul 3, «én stack, mange instanser»"
    }
}

# ===========================================================================
#  B · STATE OG KONFIGURASJON
# ===========================================================================

Write-Bolk "B · State og konfigurasjon"

# --- K5 --------------------------------------------------------------------

$backendFiler = Find-Monster -Monster 'backend\s*"azurerm"' -Sti "." -Filter "*.tf"
if ($backendFiler.Count -eq 0) {
    Write-Avvik "K5" "Tom backend `"azurerm`"-blokk" `
        "Fant ingen backend `"azurerm`"-blokk. Uten den havner state lokalt"
} else {
    $medInnhold = @()
    foreach ($rel in $backendFiler) {
        $linjer = Get-Content -Path $rel -ErrorAction SilentlyContinue
        $innhold = ""; $inblokk = $false
        foreach ($linje in $linjer) {
            if (-not $inblokk -and $linje -match 'backend\s*"azurerm"\s*\{') {
                $rest = $linje -replace '.*backend\s*"azurerm"\s*\{', ''
                if ($rest -match '\}') {
                    $innhold += ($rest -replace '\}.*', '')
                    break
                }
                $inblokk = $true
                $innhold += $rest
                continue
            }
            if ($inblokk -and $linje -match '^\s*\}') { break }
            if ($inblokk) { $innhold += $linje }
        }
        $innhold = $innhold -replace '#.*', '' -replace '//.*', ''
        $innhold = $innhold -replace '\s', ''
        if ($innhold -ne "") { $medInnhold += $rel }
    }
    if ($medInnhold.Count -eq 0) {
        Write-Ok "K5" "backend `"azurerm`"-blokka er tom"
    } else {
        Write-Avvik "K5" "backend `"azurerm`"-blokka er tom" `
            ("Fant verdier i blokka i: " + ($medInnhold -join " ") + " - de hører i -backend-config")
    }
}

# --- K6 --------------------------------------------------------------------

if ($StorageAccount -ne "") {
    $blober = az storage blob list --account-name $StorageAccount `
        --container-name $Container --auth-mode login --query "[].name" -o tsv 2>$null
    $antallBlober = 0
    $blobNavn = ""
    if ($null -ne $blober) {
        $treff = @($blober | Where-Object { $_ -match 'tfstate' })
        $antallBlober = $treff.Count
        # Navnene skal med i utskriften. Antallet alene skiller ikke to miljøer
        # fra to stacks i samme miljø - har du to stacks (K9), er fire filer
        # det normale. Den kontrollen gjør et menneske, og da trengs navnene.
        $blobNavn = ($treff -join " ")
        if ($blobNavn.Length -gt 200) { $blobNavn = $blobNavn.Substring(0, 200) }
    }
    if ($antallBlober -ge 2) {
        Write-Ok "K6" "Fant $antallBlober state-filer i ${Container}: $blobNavn"
    } elseif ($antallBlober -eq 1) {
        Write-Avvik "K6" "Én key per miljø" "Fant bare én state-fil ($blobNavn) - hvert miljø skal ha sin egen key"
    } else {
        Write-Avvik "K6" "Én key per miljø" `
            "Fant ingen state-filer i $Container på $StorageAccount. Sjekk navn og tilgang"
    }
} else {
    Write-Hoppet "K6" "Én key per miljø" `
        "Kjør på nytt med -StorageAccount <konto> -Container <navn>"
}

# --- K7 --------------------------------------------------------------------

$tfvarsHist = @(git log --all --diff-filter=A --name-only --pretty=format: -- '*.tfvars' 2>$null |
    Where-Object { $_ -ne "" } | Sort-Object -Unique)
$tfvarsNaa = @(Get-Filer -Sti "." -Filter "*.tfvars" | ForEach-Object { $_.Name })

if ($tfvarsHist.Count -eq 0 -and $tfvarsNaa.Count -eq 0) {
    Write-Ok "K7" "Ingen .tfvars i repoet eller i historikken"
} else {
    $melding = ""
    if ($tfvarsNaa.Count -gt 0)  { $melding += "I arbeidsmappa: " + ($tfvarsNaa -join " ") + " " }
    if ($tfvarsHist.Count -gt 0) { $melding += "I historikken: " + ($tfvarsHist -join " ") + " " }
    Write-Avvik "K7" "Ingen .tfvars i repoet eller i historikken" `
        ($melding + "- å slette fila i en ny commit fjerner den ikke fra historikken")
}

# --- K8 --------------------------------------------------------------------

$k8funn = ""

# Selvtestene utelates fra søket. Grunnen står på linja under: det FØRSTE
# mønsteret er en ren litteral, og skriptet du leser nå inneholder den - så
# uten denne ekskluderingen finner kontrollen seg selv og melder AVVIK på et
# repo som er helt rent. Kontrollen leser arbeidsmappa, ikke Git, så det
# hjelper ikke å la være å committe skriptet.
#
# Begge filnavnene utelates, ikke bare dette ene: studenten laster gjerne ned
# begge utgavene fra selvtest-sida og legger dem i samme mappe.
#
# De tre andre mønstrene er regexer og treffer ikke sin egen kildetekst -
# etter `client_secret` står det en `\`, ikke et likhetstegn.
$selvtester = @('sjekk-oblig.sh', 'Sjekk-Oblig.ps1')

foreach ($monster in @('AZURE_CREDENTIALS', 'client_secret\s*=', 'access_key\s*=', 'BEGIN [A-Z ]*PRIVATE KEY')) {
    $treff = @(Find-Monster -Monster $monster -Sti "." |
               Where-Object { (Split-Path $_ -Leaf) -notin $selvtester })
    if ($treff.Count -gt 0) {
        $k8funn += "[$monster] i " + ($treff -join " ") + " "
    }
}

$pwTreff = @()
foreach ($f in (Get-TfFiler)) {
    $innhold = Get-Content -Path $f.FullName -Raw -ErrorAction SilentlyContinue
    if ($null -ne $innhold -and $innhold -match '(password|secret)[a-z_]*\s*=\s*"[^"]+"') {
        $pwTreff += $f.Name
    }
}
if ($pwTreff.Count -gt 0) { $k8funn += "[passord som litteral] i " + ($pwTreff -join " ") + " " }

$stateHist = @(git log --all --diff-filter=A --name-only --pretty=format: -- '*.tfstate' 2>$null |
    Where-Object { $_ -ne "" } | Sort-Object -Unique)
if ($stateHist.Count -gt 0) { $k8funn += "[state i historikken] " + ($stateHist -join " ") + " " }

if ($k8funn -eq "") {
    Write-Ok "K8" "Ingen hemmelighet funnet i repoet"
} else {
    Write-Avvik "K8" "Ingen hemmelighet i repoet" $k8funn
}

# ===========================================================================
#  C · KOBLING
# ===========================================================================

Write-Bolk "C · Kobling"

if ((Find-Monster -Monster 'terraform_remote_state' -Sti ".").Count -gt 0) {
    Write-Ok "K9" "Den andre stacken bruker terraform_remote_state"
} else {
    Write-Avvik "K9" "terraform_remote_state" `
        "Fant ingen bruk av terraform_remote_state. Se modul 4, side 7-9"
}

# ===========================================================================
#  D · PIPELINE
# ===========================================================================

Write-Bolk "D · Pipeline"

$wfMappe = ".github/workflows"
$antallWf = 0
if (Test-Path $wfMappe) {
    $antallWf = @(Get-ChildItem -Path $wfMappe -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @('.yml', '.yaml') }).Count
}

if ($antallWf -eq 0) {
    Write-Avvik "K11" "Workflow finnes" "Fant ingen filer i $wfMappe/"
} else {
    $gammel = (Find-Monster -Monster 'creds:\s*\$\{\{\s*secrets' -Sti $wfMappe).Count
    $oidc = (Find-Monster -Monster 'id-token:\s*write' -Sti $wfMappe).Count
    $envRef = (Find-Monster -Monster '(?m)^\s*environment:' -Sti $wfMappe).Count

    if ($envRef -gt 0) {
        Write-Ok "K10" "Jobben deklarerer environment:"
    } else {
        Write-Avvik "K10" "Jobben deklarerer environment:" `
            "Uten 'environment:' matcher ikke federated credential scopet til environment"
    }

    if ($gammel -gt 0) {
        Write-Avvik "K11" "Workflowen logger inn med OIDC" `
            "Fant 'creds: `${{ secrets... }}' - det er varianten med client secret, ikke OIDC"
    } elseif ($oidc -eq 0) {
        Write-Avvik "K11" "Workflowen logger inn med OIDC" `
            "Fant ikke 'permissions: id-token: write'. Uten den får ikke jobben OIDC-token"
    } else {
        Write-Ok "K11" "Workflowen er satt opp for OIDC (id-token: write, ingen creds:)"
    }
}

# --- K10 mot Azure ---------------------------------------------------------

if ($AppId -ne "") {
    $secrets = az ad app credential list --id $AppId --query "length(@)" -o tsv 2>$null
    if ($secrets -eq "0") {
        Write-Ok "K10" "App Registration har null client secrets"
    } elseif ($null -eq $secrets -or $secrets -eq "") {
        Write-Hoppet "K10" "Null client secrets" "Fikk ikke svar fra az. Er du logget inn, og er app-id riktig?"
    } else {
        Write-Avvik "K10" "Null client secrets" `
            "Fant $secrets client secret(s). Slett dem - hele poenget er at de ikke skal finnes"
    }

    $subjects = @(az ad app federated-credential list --id $AppId --query "[].subject" -o tsv 2>$null |
        Where-Object { $_ -ne "" })
    if ($subjects.Count -eq 0) {
        Write-Hoppet "K10" "Federated credential scopet til environment" "Fant ingen federated credentials"
    } else {
        $feilScope = @($subjects | Where-Object { $_ -notmatch ':environment:' })
        $harTall = @($subjects | Where-Object { $_ -match ':\d{6,}' })
        if ($feilScope.Count -gt 0) {
            Write-Avvik "K10" "Federated credential scopet til environment" `
                ("Disse er ikke scopet til environment: " + ($feilScope -join " "))
        } elseif ($harTall.Count -gt 0) {
            Write-Avvik "K10" "Subject-strengen inneholder tall" `
                "Subject skal være repo:<org>/<repo>:environment:<miljø> uten ID-tall. Gir AADSTS700213"
        } else {
            Write-Ok "K10" "Federated credentials er scopet til environment"
        }
    }
} else {
    Write-Hoppet "K10" "Client secrets og subject-streng" "Kjør på nytt med -AppId <app-id>"
}

Write-Manuell "K11" "az account show viser service principal, ikke deg" `
    "Lever utskriften fra workflowen ved siden av den lokale"
Write-Manuell "K12" "Andre kjøring gir No changes" `
    "Kjør workflowen to ganger uten å endre noe, og lever plan-utskriften"

# ===========================================================================
#  Oppsummering
# ===========================================================================

Write-Host ""
Write-Host "---------------------------------------------" -ForegroundColor DarkGray
Write-Host "  OK: $($script:AntallOk)" -ForegroundColor Green -NoNewline
Write-Host "   Avvik: $($script:AntallAvvik)" -ForegroundColor Red -NoNewline
Write-Host "   Manuell: $($script:AntallManuell)" -ForegroundColor Yellow -NoNewline
Write-Host "   Hoppet over: $($script:AntallHoppet)" -ForegroundColor DarkGray

if ($script:AntallAvvik -gt 0) {
    $unike = ($script:Avviksliste | Sort-Object -Unique) -join " "
    Write-Host ""
    Write-Host "  Avvik på: $unike"
    Write-Host "  Rett dem, og kjør skriptet på nytt." -ForegroundColor DarkGray
    Write-Host ""
    exit 1
}

if ($script:AntallHoppet -gt 0) {
    Write-Host ""
    Write-Host "  Ingen avvik, men noen kontroller ble hoppet over." -ForegroundColor Yellow
    Write-Host "  Kjør med -AppId og -StorageAccount før du leverer." -ForegroundColor DarkGray
    Write-Host ""
    exit 0
}

Write-Host ""
Write-Host "  Ingen avvik. Husk de manuelle utskriftene i innleveringen." -ForegroundColor Green
Write-Host ""
exit 0
