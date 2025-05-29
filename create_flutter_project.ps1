Set-Location "C:\Users\yerim\figma_project"
Remove-Item -Path "campuspool_app" -Recurse -Force -ErrorAction SilentlyContinue
$projectPath = "C:\Users\yerim\figma_project\campuspool_app"
flutter create $projectPath
if (Test-Path $projectPath) {
    $acl = Get-Acl $projectPath
    $permission = "DESKTOP-TQHP66T\PC","FullControl","ContainerInherit,ObjectInherit","None","Allow"
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
    $acl.SetAccessRule($accessRule)
    Set-Acl $projectPath $acl
    Get-ChildItem $projectPath -Recurse | ForEach-Object {
        Set-Acl $_.FullName $acl
    }
}
Write-Host "Press Enter to exit..."
$null = Read-Host
