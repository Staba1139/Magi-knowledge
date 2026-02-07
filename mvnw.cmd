@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Apache Maven Wrapper startup batch script, version 3.3.2
@REM
@REM Optional ENV vars
@REM   MVNW_REPOURL - repo url base for downloading maven distribution
@REM   MVNW_USERNAME/MVNW_PASSWORD - user and password for downloading maven
@REM   MVNW_VERBOSE - true: enable verbose log; others: silence the output
@REM ----------------------------------------------------------------------------

@IF "%__MVNW_ARG0_NAME__%"=="" (SET __MVNW_ARG0_NAME__=%~nx0)
@SET __MVNW_CMD__=
@SET __MVNW_ERROR__=
@SET __MVNW_PSMODULEP_SAVE=%PSModulePath%
@SET PSModulePath=
@FOR /F "usebackq tokens=1* delims==" %%A IN (`powershell -noprofile "& {$scriptDir='%~dp0telemedicus'; $, $distributionUrl = (Get-Content -Raw '%~dp0.mvn\wrapper\maven-wrapper.properties') -split '\r?\n' |ForEach-Object {$_.Trim()} |Where-Object {$_ -match '^distributionUrl\s*='} |ForEach-Object {$_ -replace '^distributionUrl\s*=\s*',''}; $mvndist = $distributionUrl -replace '^.*\/', '' -replace '\.zip$', ''; $mvnHome = [System.IO.Path]::Combine($env:USERPROFILE, '.m2', 'wrapper', 'dists', $mvndist); if (Test-Path \"$mvnHome\bin\mvn.cmd\") {Write-Output \"MVNW_CMD=$mvnHome\bin\mvn.cmd\"} else {$zipFile = \"$mvnHome.zip\"; if (-not (Test-Path $zipFile)) {[System.IO.Directory]::CreateDirectory([System.IO.Path]::GetDirectoryName($zipFile)) >$null; if ($env:MVNW_USERNAME -and $env:MVNW_PASSWORD) {$cred = New-Object System.Net.NetworkCredential($env:MVNW_USERNAME, $env:MVNW_PASSWORD); $wc = New-Object System.Net.WebClient; $wc.Credentials = $cred} else {$wc = New-Object System.Net.WebClient}; if ($env:MVNW_VERBOSE -eq 'true') {Write-Output \"Downloading from $distributionUrl\"}; try {$wc.DownloadFile($distributionUrl, $zipFile)} catch {$msg = $_.Exception.Message; Write-Output \"MVNW_ERROR=Error: Failed to download $distributionUrl - $msg\"}}; if (Test-Path $zipFile) {if ($env:MVNW_VERBOSE -eq 'true') {Write-Output \"Extracting $zipFile\"}; try {Expand-Archive $zipFile -DestinationPath $mvnHome -Force; Write-Output \"MVNW_CMD=$mvnHome\bin\mvn.cmd\"} catch {Write-Output \"MVNW_ERROR=Error: Failed to extract $zipFile\"}}}}"`) DO @(
  @IF NOT "%%A"=="" @SET "%%A=%%B"
)
@SET PSModulePath=%__MVNW_PSMODULEP_SAVE%
@IF NOT "%__MVNW_ERROR__%"=="" (@ECHO.%__MVNW_ERROR__% & @EXIT /b 1)
@IF NOT "%__MVNW_CMD__%"=="" (%__MVNW_CMD__% %*)
