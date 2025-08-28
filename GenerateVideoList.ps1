param(
    # 定义一个参数 TargetFolder，用于接收用户指定的文件夹路径
    # 如果用户没有提供，则默认为当前脚本所在的目录 ($PSScriptRoot)
    # 如果是从交互式 PowerShell 运行且未提供参数，会提示用户输入
    [Parameter(Mandatory=$false)]
    [string]$TargetFolder = $PSScriptRoot 
)

# 定义视频文件扩展名列表
$videoExtensions = @("*.mp4", "*.avi", "*.mkv", "*.mov", "*.wmv", "*.flv", "*.webm", "*.m4v", "*.mpg", "*.mpeg", "*.3gp", "*.ogv")

# 解析并验证目标文件夹路径
try {
    # 确保路径是绝对路径
    $resolvedTargetFolder = Convert-Path -Path $TargetFolder -ErrorAction Stop
    Write-Host "正在搜索文件夹: $resolvedTargetFolder"
} catch {
    Write-Error "指定的文件夹路径无效或无法访问: $TargetFolder"
    exit 1
}

# 确保目标路径以目录分隔符结尾，以便字符串替换正确
$resolvedTargetPathForComparison = $resolvedTargetFolder
if (-not $resolvedTargetPathForComparison.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $resolvedTargetPathForComparison += [System.IO.Path]::DirectorySeparatorChar
}

# 查找指定目录及所有子目录下的视频文件
# -Recurse 表示递归搜索子文件夹
# -File 表示只返回文件，不返回文件夹
$videoFiles = Get-ChildItem -Path $resolvedTargetFolder -Include $videoExtensions -Recurse -File -ErrorAction SilentlyContinue

if ($videoFiles.Count -eq 0) {
    Write-Warning "在指定文件夹 '$resolvedTargetFolder' 及其子文件夹中未找到任何视频文件。"
}

# 准备 JavaScript 数组内容
$jsArrayContent = "const videoList = [`n"

# 遍历找到的视频文件，将相对路径添加到 JavaScript 数组中
foreach ($file in $videoFiles) {
    try {
        # 获取文件的完整路径
        $fullPath = $file.FullName

        # 手动计算相对路径：通过移除目标文件夹的绝对路径前缀
        # 确保比较的路径格式一致
        if ($fullPath.StartsWith($resolvedTargetPathForComparison, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $fullPath.Substring($resolvedTargetPathForComparison.Length)
        } else {
            # 如果由于某种原因前缀不匹配（理论上不应该），则回退到使用 Resolve-Path -Relative
            Write-Warning "手动计算相对路径失败，尝试备用方法: $fullPath"
            $relativePath = Resolve-Path -Path $fullPath -RelativeBasePath $resolvedTargetFolder -ErrorAction Stop
            if ($relativePath.StartsWith(".\")) {
                $relativePath = $relativePath.Substring(2)
            }
        }

        # 将路径中的反斜杠 \ 替换为正斜杠 /，这在 JavaScript 字符串和 URL 中更通用
        $jsFriendlyPath = $relativePath.Replace('\', '/')

        # 将路径添加到数组内容中，并用双引号包裹，用逗号和换行符分隔
        $jsArrayContent += "    ""$jsFriendlyPath"",`n"
    } catch {
        Write-Warning "无法处理文件: $($file.FullName). 错误: $_"
    }
}

# 完成 JavaScript 数组的构建
# 移除最后一个多余的逗号和换行符（如果有的话）
if ($jsArrayContent.EndsWith(",`n")) {
    $jsArrayContent = $jsArrayContent.Substring(0, $jsArrayContent.Length - 2)
}
$jsArrayContent += "`n];`n`n// 可选：在浏览器控制台或 Node.js 环境中打印列表以验证`n// console.log(videoList);`n"

# 定义输出文件路径 (输出到脚本所在目录或当前工作目录)
$outputDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$outputFilePath = Join-Path -Path $outputDir -ChildPath "videoList.js"

# 将内容写入 videoList.js 文件
# -Encoding UTF8 确保文件以 UTF-8 编码保存
try {
    Set-Content -Path $outputFilePath -Value $jsArrayContent -Encoding UTF8 -ErrorAction Stop
    Write-Host "视频列表已成功生成并保存到: $outputFilePath"
} catch {
    Write-Error "写入文件失败: $outputFilePath. 错误: $_"
    exit 1
}



