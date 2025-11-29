Athbatch_strandness_check.sh# Athbatch_strandness_check.sh: Batch Identification of RNA-seq Strandness

A bash script for batch determining the strandness of paired-end RNA-seq data, generating a summary report, and sending notifications via email.





## **Function**

This script automates the process of identifying strandness (FR-strand-specific, RF-strand-specific, weak strand-specific, or non-strand-specific) for multiple paired-end RNA-seq samples. It performs the following steps:

1. Samples a subset of reads from raw fastq files to speed up analysis.
2. Aligns sampled reads to a reference genome using Hisat2.
3. Infers strandness using `infer_experiment.py` (from RSeQC).
4. Summarizes results into a CSV file.
5. Cleans up temporary files and sends a completion notification via email.

## **Dependencies**

Ensure the following tools are installed and available in your `$PATH`:

- **Bash environment**: For script execution.
- **Hisat2**: For aligning RNA-seq reads to the reference genome.
- **Samtools**: For processing BAM files (used to convert SAM to BAM).
- **Python 3**: Required for running `infer_experiment.py`.
- **RSeQC**: Contains `infer_experiment.py` (essential for strandness inference).
- **mailx + msmtp**: For sending email notifications (configure SMTP settings in advance).

Additionally, prepare:

- A reference genome index built with Hisat2.
- A gene annotation BED file (matching the reference genome, for `infer_experiment.py`).

## **Usage**

### **1. Prepare Input Data**

- Place all paired-end raw RNA-seq files in a directory (e.g., `./1raw_data`).
- File naming convention: Paired-end files must follow `*_1.fastq.gz` (read 1) and `*_2.fastq.gz` (read 2) (modify `SAMPLE_SUFFIX` if your naming differs).

### **2. Modify Parameters**

Edit the "User-defined parameters" section in `Athbatch_strandness_check.sh` according to your data:

| Parameter        | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| `RAW_DATA_DIR`   | Path to the directory containing raw fastq files (e.g., `./1raw_data`). |
| `REF_INDEX`      | Path to the Hisat2 reference genome index (without suffixes). |
| `ANNOTATION_BED` | Path to the gene annotation BED file (matches the reference genome). |
| `SAMPLE_SUFFIX`  | Suffix of read 1 files (e.g., `_1.fastq.gz`; ensure consistency with your data). |
| `THREADS`        | Number of threads for alignment (adjust based on CPU cores, e.g., 8). |
| `SAMPLE_READS`   | Number of reads to sample per end (200,000–300,000 is typically sufficient). |
| `OUTPUT_CSV`     | Name of the output CSV summary file (e.g., `Ara_strandness_summary.csv`). |
| `receiver`       | Email address to receive completion notifications.           |

### **3. Run the Script**

Execute the script in the bash environment:

bash

运行

```bash
bash Athbatch_strandness_check.sh
```

## **Output**

A CSV file (specified by `OUTPUT_CSV`) with the following columns descriptions:

| Column Name                   | Description                                                  |
| ----------------------------- | ------------------------------------------------------------ |
| `Sample_Name`                 | Name of the sample.                                          |
| `Fraction_Failed`             | Proportion of reads that could not be used for strandness inference (smaller is better). |
| `A_FR_mode`                   | Proportion of reads matching FR-strand-specific patterns (1++,1--,2+-,2-+). |
| `B_RF_mode`                   | Proportion of reads matching RF-strand-specific patterns (1+-,1-+,2++,2--). |
| `A-B_diff`                    | Difference between `A_FR_mode` and `B_RF_mode` (positive = FR bias; negative = RF bias). |
| `Strandness_Type`             | Inferred strandness (FR-strand-specific, RF-strand-specific, Weak FR/RF, or Non-strand-specific). |
| `Recommended_StringTie_Param` | Recommended strandness parameter for StringTie (`--fr`, `--rf`, or `None`). |

## **Notes**

- **Temporary Files**: Intermediate files (sampled fastqs and BAMs) are automatically deleted after processing to save disk space.
- **Email Notifications**: Ensure `mailx` and `msmtp` are configured correctly (SMTP server, authentication) to receive notifications.
- **Sampling**: Reducing `SAMPLE_READS` speeds up analysis but may reduce accuracy; 200,000–300,000 reads are recommended.
- **Paired-end Checks**: The script skips samples if their paired read 2 file is missing (logs a warning).

## **Troubleshooting**

- **Missing Dependencies**: Ensure all tools (Hisat2, samtools, RSeQC, etc.) are installed and in `$PATH`.

- **Alignment Failures**: Verify the reference genome index (`REF_INDEX`) is valid and matches the annotation BED file.

- **Email Issues**: Check `msmtp` configuration (e.g., `~/.msmtprc`) for correct SMTP settings.# Athbatch_strandness_check.sh: Batch Identification of RNA-seq Strandness

  

  A bash script for batch determining the strandness of paired-end RNA-seq data, generating a summary report, and sending notifications via email.

## **Function**

This script automates the process of identifying strandness (FR-strand-specific, RF-strand-specific, weak strand-specific, or non-strand-specific) for multiple paired-end RNA-seq samples. It performs the following steps:

1. Samples a subset of reads from raw fastq files to speed up analysis.
2. Aligns sampled reads to a reference genome using Hisat2.
3. Infers strandness using `infer_experiment.py` (from RSeQC).
4. Summarizes results into a CSV file.
5. Cleans up temporary files and sends a completion notification via email.

## **Dependencies**

Ensure the following tools are installed and available in your `$PATH`:

- **Bash environment**: For script execution.
- **Hisat2**: For aligning RNA-seq reads to the reference genome.
- **Samtools**: For processing BAM files (used to convert SAM to BAM).
- **Python 3**: Required for running `infer_experiment.py`.
- **RSeQC**: Contains `infer_experiment.py` (essential for strandness inference).
- **mailx + msmtp**: For sending email notifications (configure SMTP settings in advance).

Additionally, prepare:

- A reference genome index built with Hisat2.
- A gene annotation BED file (matching the reference genome, for `infer_experiment.py`).

## **Usage**

### **1. Prepare Input Data**

- Place all paired-end raw RNA-seq files in a directory (e.g., `./1raw_data`).
- File naming convention: Paired-end files must follow `*_1.fastq.gz` (read 1) and `*_2.fastq.gz` (read 2) (modify `SAMPLE_SUFFIX` if your naming differs).

### **2. Modify Parameters**

Edit the "User-defined parameters" section in `Athbatch_strandness_check.sh` according to your data:

| Parameter        | Description                                                  |
| ---------------- | ------------------------------------------------------------ |
| `RAW_DATA_DIR`   | Path to the directory containing raw fastq files (e.g., `./1raw_data`). |
| `REF_INDEX`      | Path to the Hisat2 reference genome index (without suffixes). |
| `ANNOTATION_BED` | Path to the gene annotation BED file (matches the reference genome). |
| `SAMPLE_SUFFIX`  | Suffix of read 1 files (e.g., `_1.fastq.gz`; ensure consistency with your data). |
| `THREADS`        | Number of threads for alignment (adjust based on CPU cores, e.g., 8). |
| `SAMPLE_READS`   | Number of reads to sample per end (200,000–300,000 is typically sufficient). |
| `OUTPUT_CSV`     | Name of the output CSV summary file (e.g., `Ara_strandness_summary.csv`). |
| `receiver`       | Email address to receive completion notifications.           |

### **3. Run the Script**

Execute the script in the bash environment:

bash

运行



```bash
bash Athbatch_strandness_check.sh
```

## **Output**

A CSV file (specified by `OUTPUT_CSV`) with the following columns descriptions:

| Column Name                   | Description                                                  |
| ----------------------------- | ------------------------------------------------------------ |
| `Sample_Name`                 | Name of the sample.                                          |
| `Fraction_Failed`             | Proportion of reads that could not be used for strandness inference (smaller is better). |
| `A_FR_mode`                   | Proportion of reads matching FR-strand-specific patterns (1++,1--,2+-,2-+). |
| `B_RF_mode`                   | Proportion of reads matching RF-strand-specific patterns (1+-,1-+,2++,2--). |
| `A-B_diff`                    | Difference between `A_FR_mode` and `B_RF_mode` (positive = FR bias; negative = RF bias). |
| `Strandness_Type`             | Inferred strandness (FR-strand-specific, RF-strand-specific, Weak FR/RF, or Non-strand-specific). |
| `Recommended_StringTie_Param` | Recommended strandness parameter for StringTie (`--fr`, `--rf`, or `None`). |

## **Notes**

- **Temporary Files**: Intermediate files (sampled fastqs and BAMs) are automatically deleted after processing to save disk space.
- **Email Notifications**: Ensure `mailx` and `msmtp` are configured correctly (SMTP server, authentication) to receive notifications.
- **Sampling**: Reducing `SAMPLE_READS` speeds up analysis but may reduce accuracy; 200,000–300,000 reads are recommended.
- **Paired-end Checks**: The script skips samples if their paired read 2 file is missing (logs a warning).

## **Troubleshooting**

- **Missing Dependencies**: Ensure all tools (Hisat2, samtools, RSeQC, etc.) are installed and in `$PATH`.
- **Alignment Failures**: Verify the reference genome index (`REF_INDEX`) is valid and matches the annotation BED file.
- **Email Issues**: Check `msmtp` configuration (e.g., `~/.msmtprc`) for correct SMTP settings.



# Software

Athbatch_strandness_check.sh以下是针对脚本 `Athbatch_strandness_check.sh` 所需软件的配置说明，补充了各依赖工具的安装、配置步骤及注意事项：

### 软件配置说明

该脚本依赖多个生物信息学工具和系统工具，需提前安装并正确配置，确保在环境变量 `$PATH` 中可调用。以下是详细配置步骤：

#### 1. 基础环境（Linux/WSL）

- **系统要求**：Linux 发行版（如 Ubuntu 20.04+）或 Windows Subsystem for Linux (WSL 2)。
- **bash**：系统默认自带，无需额外配置。

#### 2. Hisat2（reads 比对工具）

**功能**：将抽样的 RNA-seq reads 比对到参考基因组。

**安装方法**：

- 方法 1（apt 安装，适合 Ubuntu/Debian）：

  bash

  运行

  ```bash
  sudo apt update && sudo apt install hisat2
  ```

  方法 2（conda 安装，跨平台推荐）：

  bash

  运行

  

  ```bash
  conda install -c bioconda hisat2
  ```

  **配置要求**：

- 需提前用 Hisat2 构建参考基因组索引（脚本中 `REF_INDEX` 参数指向索引路径）。

- 索引构建命令示例（以拟南芥基因组为例）：

  bash

  运行

  ```bash
  hisat2-build -p 8 Arabidopsis_thaliana.TAIR10.dna.toplevel.fa Arahisat24  # 生成前缀为"Arahisat24"的索引文件
  ```

  3. Samtools（BAM 文件处理工具）

**功能**：将 Hisat2 输出的 SAM 格式转为 BAM 格式。

**安装方法**：

- 方法 1（apt 安装）：

  bash

  

  运行

  

  

  

  

  ```bash
  sudo apt install samtools
  ```

  

- 方法 2（conda 安装）：

  bash

  

  运行

  

  

  

  

  ```bash
  conda install -c bioconda samtools
  ```

  4. Python 3 及 RSeQC（链特异性判定工具）

**功能**：`infer_experiment.py`（来自 RSeQC 包）用于推断链特异性。

**安装步骤**：

1. 安装 Python 3（系统通常自带，如需升级）：

   bash

   运行

   ```bash
   sudo apt install python3 python3-pip
   ```

   

2. 安装 RSeQC（包含 `infer_experiment.py`）：

   bash

   运行

   ```bash
   pip3 install RSeQC  # 或用 conda: conda install -c bioconda rseqc
   ```

   

**验证配置**：以下是针对脚本 `Athbatch_strandness_check.sh` 所需软件的配置说明，补充了各依赖工具的安装、配置步骤及注意事项：

### 软件配置说明

该脚本依赖多个生物信息学工具和系统工具，需提前安装并正确配置，确保在环境变量 `$PATH` 中可调用。以下是详细配置步骤：

#### 1. 基础环境（Linux/WSL）

- **系统要求**：Linux 发行版（如 Ubuntu 20.04+）或 Windows Subsystem for Linux (WSL 2)。
- **bash**：系统默认自带，无需额外配置。

#### 2. Hisat2（reads 比对工具）

​	**功能**：将抽样的 RNA-seq reads 比对到参考基因组。

**	安装方法**：

- 方法 1（apt 安装，适合 Ubuntu/Debian）：

  bash

  运行

  ```bash
  sudo apt update && sudo apt install hisat2
  ```

  方法 2（conda 安装，跨平台推荐）：

  bash

  运行

  ```bash
  conda install -c bioconda hisat2
  ```

  

- ```bash
  hisat2-build -p 8 Arabidopsis_thaliana.TAIR10.dna.toplevel.fa Arahisat24  # 生成前缀为"Arahisat24"的索引文件
  ```

  #### 3. Samtools（BAM 文件处理工具）

**功能**：将 Hisat2 输出的 SAM 格式转为 BAM 格式。

**安装方法**：

- 方法 1（apt 安装）：

  ```bash
  sudo apt install samtools
  ```

  

- 方法 2（conda 安装）：

  bash

  运行

  ```bash
  conda install -c bioconda samtools
  ```

  4. #### Python 3 及 RSeQC（链特异性判定工具）

**功能**：`infer_experiment.py`（来自 RSeQC 包）用于推断链特异性。

**安装步骤**：

1. 安装 Python 3（系统通常自带，如需升级）：

   bash

   运行

   ```bash
   sudo apt install python3 python3-pip
   ```

   安装 RSeQC（包含 `infer_experiment.py`）：

   bash运行

   ```bash
   pip3 install RSeQC  # 或用 conda: conda install -c bioconda rseqc
   ```

   #### 5. RSeQC 工具验证与注释文件准备

**`infer_experiment.py` 验证**：

bash运行

```bash
infer_experiment.py -h  # 查看帮助信息，确认无报错
```

若提示 “command not found”，需将 Python 脚本安装路径添加到环境变量（例如，若安装在 `~/.local/bin`）：

bash运行

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**注释文件（BED）要求**：

`ANNOTATION_BED` 需为 RSeQC 兼容的 BED 格式（需包含染色体、起始位置、终止位置、基因名、得分、链信息）。可通过基因组注释文件（如 GTF）转换生成，示例工具：`gtf2bed`（来自 BEDOPS 工具包）：

bash运行

```bash
conda install -c bioconda bedops  # 安装BEDOPS
gtf2bed < Arabidopsis_thaliana.TAIR10.55.gtf > Arabisopsis-RSeQC.bed  # GTF转BED
```

#### 6. bc 工具（数值计算依赖）

**功能**：脚本中用于浮点数运算（如计算 `A_B_diff` 和判断阈值）。

**安装方法**：

bash运行

```bash
sudo apt install bc  # Ubuntu/Debian
# 或通过conda：
conda install -c conda-forge bc
```

#### 7. mailx + msmtp（邮件通知配置）

**功能**：脚本运行结束后发送邮件通知，需提前配置 SMTP 服务。

##### 安装步骤：

bash运行

```bash
sudo apt install mailx msmtp  # 安装工具
```

##### 配置 SMTP（关键步骤）：

1. 创建 / 编辑 msmtp 配置文件 `~/.msmtprc`：

   bash运行

   ```bash
   nano ~/.msmtprc
   ```

   填入 SMTP 服务器信息（以网易邮箱为例，其他邮箱需替换对应参数）：

   ini

   ```ini
   account default
   host smtp.163.com  # SMTP服务器地址（如QQ邮箱为smtp.qq.com）
   port 465           # 端口（SSL通常用465，TLS用587）
   from your_email@163.com  # 发件人邮箱
   auth on            # 开启认证
   user your_email@163.com  # 发件人邮箱账号
   password your_auth_code  # 邮箱授权码（非登录密码，需在邮箱设置中开启SMTP并获取）
   tls on             # 开启TLS加密
   tls_starttls off   # 若端口为465，设为off；587则设为on
   logfile ~/.msmtp.log  # 日志文件（可选）
   ```

   设置文件权限（避免权限过高导致错误）：

   bash运行

   ```bash
   chmod 600 ~/.msmtprc
   ```

   配置 mailx：

创建 / 编辑 mailx 配置文件 `~/.mailrc`：

bash

运行

```bash
nano ~/.mailrc
```

添加内容：

```ini
set sendmail="/usr/bin/msmtp"
set from="your_email@163.com"  # 与msmtp配置中的发件人一致
```

##### 验证邮件发送：

```bash
echo "测试邮件内容" | mailx -s "测试邮件标题" receiver@example.com
```

若接收成功，则配置生效。

#### 8. 日志文件生成（可选）

脚本运行过程中可生成日志文件，便于排查错误：

bash运行

```bash
bash Athbatch_strandness_check.sh > batch_strandness_check.sh.log 2>&1
```

日志文件会记录所有输出信息（包括警告和错误），对应脚本中 `mail_content` 提到的 `batch_strandness_check.sh.log`。

### 常见问题与解决方案

1. **抽样失败**：

   若提示 `zcat: command not found`，需安装 `zutils`：

   bash

   运行

   ```bash
   sudo apt install zutils
   ```

   **Hisat2 比对报错 “index not found”**：

   检查 `REF_INDEX` 参数是否指向正确的索引前缀（需确保索引文件与前缀匹配，如 `Arahisat24.1.ht2` 等）。

2. **邮件发送失败**：

   - 检查 `~/.msmtprc` 中 SMTP 服务器、端口、授权码是否正确。
   - 查看日志 `~/.msmtp.log` 定位具体错误（如网络问题、认证失败）。

3. **浮点数计算错误**：

   若提示 `bc: command not found`，按步骤 6 安装 `bc` 工具。

通过以上配置，脚本可正常运行并完成 RNA-seq 链特异性的批量鉴定。





