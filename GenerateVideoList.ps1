param(
    # ����һ������ TargetFolder�����ڽ����û�ָ�����ļ���·��
    # ����û�û���ṩ����Ĭ��Ϊ��ǰ�ű����ڵ�Ŀ¼ ($PSScriptRoot)
    # ����Ǵӽ���ʽ PowerShell ������δ�ṩ����������ʾ�û�����
    [Parameter(Mandatory=$false)]
    [string]$TargetFolder = $PSScriptRoot 
)

# ������Ƶ�ļ���չ���б�
$videoExtensions = @("*.mp4", "*.avi", "*.mkv", "*.mov", "*.wmv", "*.flv", "*.webm", "*.m4v", "*.mpg", "*.mpeg", "*.3gp", "*.ogv")

# ��������֤Ŀ���ļ���·��
try {
    # ȷ��·���Ǿ���·��
    $resolvedTargetFolder = Convert-Path -Path $TargetFolder -ErrorAction Stop
    Write-Host "���������ļ���: $resolvedTargetFolder"
} catch {
    Write-Error "ָ�����ļ���·����Ч���޷�����: $TargetFolder"
    exit 1
}

# ȷ��Ŀ��·����Ŀ¼�ָ�����β���Ա��ַ����滻��ȷ
$resolvedTargetPathForComparison = $resolvedTargetFolder
if (-not $resolvedTargetPathForComparison.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
    $resolvedTargetPathForComparison += [System.IO.Path]::DirectorySeparatorChar
}

# ����ָ��Ŀ¼��������Ŀ¼�µ���Ƶ�ļ�
# -Recurse ��ʾ�ݹ��������ļ���
# -File ��ʾֻ�����ļ����������ļ���
$videoFiles = Get-ChildItem -Path $resolvedTargetFolder -Include $videoExtensions -Recurse -File -ErrorAction SilentlyContinue

if ($videoFiles.Count -eq 0) {
    Write-Warning "��ָ���ļ��� '$resolvedTargetFolder' �������ļ�����δ�ҵ��κ���Ƶ�ļ���"
}

# ׼�� JavaScript ��������
$jsArrayContent = "const videoList = [`n"

# �����ҵ�����Ƶ�ļ��������·����ӵ� JavaScript ������
foreach ($file in $videoFiles) {
    try {
        # ��ȡ�ļ�������·��
        $fullPath = $file.FullName

        # �ֶ��������·����ͨ���Ƴ�Ŀ���ļ��еľ���·��ǰ׺
        # ȷ���Ƚϵ�·����ʽһ��
        if ($fullPath.StartsWith($resolvedTargetPathForComparison, [System.StringComparison]::OrdinalIgnoreCase)) {
            $relativePath = $fullPath.Substring($resolvedTargetPathForComparison.Length)
        } else {
            # �������ĳ��ԭ��ǰ׺��ƥ�䣨�����ϲ�Ӧ�ã�������˵�ʹ�� Resolve-Path -Relative
            Write-Warning "�ֶ��������·��ʧ�ܣ����Ա��÷���: $fullPath"
            $relativePath = Resolve-Path -Path $fullPath -RelativeBasePath $resolvedTargetFolder -ErrorAction Stop
            if ($relativePath.StartsWith(".\")) {
                $relativePath = $relativePath.Substring(2)
            }
        }

        # ��·���еķ�б�� \ �滻Ϊ��б�� /������ JavaScript �ַ����� URL �и�ͨ��
        $jsFriendlyPath = $relativePath.Replace('\', '/')

        # ��·����ӵ����������У�����˫���Ű������ö��źͻ��з��ָ�
        $jsArrayContent += "    ""$jsFriendlyPath"",`n"
    } catch {
        Write-Warning "�޷������ļ�: $($file.FullName). ����: $_"
    }
}

# ��� JavaScript ����Ĺ���
# �Ƴ����һ������Ķ��źͻ��з�������еĻ���
if ($jsArrayContent.EndsWith(",`n")) {
    $jsArrayContent = $jsArrayContent.Substring(0, $jsArrayContent.Length - 2)
}
$jsArrayContent += "`n];`n`n// ��ѡ�������������̨�� Node.js �����д�ӡ�б�����֤`n// console.log(videoList);`n"

# ��������ļ�·�� (������ű�����Ŀ¼��ǰ����Ŀ¼)
$outputDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$outputFilePath = Join-Path -Path $outputDir -ChildPath "videoList.js"

# ������д�� videoList.js �ļ�
# -Encoding UTF8 ȷ���ļ��� UTF-8 ���뱣��
try {
    Set-Content -Path $outputFilePath -Value $jsArrayContent -Encoding UTF8 -ErrorAction Stop
    Write-Host "��Ƶ�б��ѳɹ����ɲ����浽: $outputFilePath"
} catch {
    Write-Error "д���ļ�ʧ��: $outputFilePath. ����: $_"
    exit 1
}



