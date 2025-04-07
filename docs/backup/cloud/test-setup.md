# Cloud Backup Test Setup Plan

## Test Environment
### Primary Test Platform (Fedora)
- OS: Fedora Linux
- Test Directory Structure:
  ```
  ~/backup-test/
  ├── small-files/     # 1000 files < 1MB
  ├── medium-files/    # 100 files 1-100MB
  ├── large-files/     # 10 files > 100MB
  └── dedup-test/      # Duplicate file variants
  ```

## Test Cases

### 1. Wasabi (with rclone)
#### Setup Steps
```bash
# Install rclone
sudo dnf install rclone

# Configure test directory
mkdir -p ~/backup-test/{small-files,medium-files,large-files,dedup-test}

# Configure rclone (interactive)
rclone config

# Test connection
rclone lsd wasabi:
```

#### Test Scenarios
1. Basic Upload Test
   ```bash
   # Time the upload of test files
   time rclone copy ~/backup-test wasabi:backup-test
   ```

2. Deduplication Test
   ```bash
   # Create duplicate files with minor changes
   cp ~/backup-test/medium-files/* ~/backup-test/dedup-test/
   # Modify files slightly
   # Sync and monitor storage usage
   rclone sync ~/backup-test wasabi:backup-test
   ```

### 2. SpiderOak One
#### Setup Steps
```bash
# Download RPM package
wget https://spideroak.com/release/spideroak/rpm_x64

# Install package
sudo dnf install ./spideroak-*.rpm

# Initial configuration
SpiderOakONE --setup=-
```

#### Test Scenarios
1. Initial Backup Test
   - Configure backup set for ~/backup-test
   - Monitor initial backup performance
   - Verify completion and integrity

2. Incremental Backup Test
   - Modify test files
   - Monitor incremental backup behavior
   - Verify version retention

### 3. pCloud
#### Setup Steps
```bash
# Download AppImage
wget https://pcloud.com/download_linux.html -O pcloud

# Make executable
chmod +x pcloud

# Run and configure
./pcloud
```

#### Test Scenarios
1. Drive Mount Test
   - Verify native filesystem mounting
   - Test file operations through mounted drive
   - Check extended attribute preservation

2. Sync Folder Test
   - Configure ~/backup-test as sync folder
   - Monitor initial sync
   - Test file modifications

### 4. CrashPlan
#### Setup Steps
```bash
# Install Java requirement
sudo dnf install java-11-openjdk

# Download and install CrashPlan
wget https://download.crashplan.com/installs/linux/install/CrashPlan.tgz
tar -xzf CrashPlan.tgz
cd crashplan-install
sudo ./install.sh
```

#### Test Scenarios
1. Backup Set Configuration
   - Configure backup set for ~/backup-test
   - Monitor resource usage during initial backup
   - Test backup throttling settings

2. Recovery Test
   - Simulate file deletion
   - Test restore functionality
   - Verify file integrity post-restore

## Test Data Generation
```bash
# Generate test files
mkdir -p ~/backup-test/{small-files,medium-files,large-files,dedup-test}

# Small files (1000 files < 1MB)
for i in {1..1000}; do
    dd if=/dev/urandom of=~/backup-test/small-files/file$i.dat bs=1K count=$((RANDOM % 1000 + 1))
done

# Medium files (100 files 1-100MB)
for i in {1..100}; do
    dd if=/dev/urandom of=~/backup-test/medium-files/file$i.dat bs=1M count=$((RANDOM % 100 + 1))
done

# Large files (10 files > 100MB)
for i in {1..10}; do
    dd if=/dev/urandom of=~/backup-test/large-files/file$i.dat bs=1M count=$((RANDOM % 900 + 100))
done
```

## Success Criteria
1. Basic Functionality
   - Successful initial backup
   - Successful incremental updates
   - Successful file restoration

2. Performance Metrics
   - Initial backup speed
   - Incremental backup speed
   - Resource usage (CPU, RAM)

3. Deduplication Efficiency
   - Storage savings with duplicate files
   - Storage savings with similar files

4. Reliability
   - No failed transfers
   - Consistent performance
   - Stable system operation

Next Steps: Proceed to Final Comparison and Decision
