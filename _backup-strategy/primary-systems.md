---
layout: page
title: Primary Backup Systems
permalink: /backup-strategy/primary-systems/
description: Details of our primary backup systems - Duplicity and Borg
---

# Primary Backup Systems

Our primary backup systems provide comprehensive protection through a combination of Duplicity and Borg backup tools, both storing data in Backblaze B2 cloud storage.

## Duplicity Configuration

Duplicity creates encrypted, incremental backups to remote storage:

```bash
# Example Duplicity backup command
duplicity --encrypt-key KEY_ID --exclude-filelist exclude.txt /home/user \
  b2://bucket-name/backup-dir
```

Key features:

- GPG encryption for all backups
- Incremental backups to minimize bandwidth
- Full backups on a weekly schedule
- 90-day retention policy with automated cleanup

## Borg Backup Management

Borg creates efficient, deduplicated backups:

```bash
# Example Borg backup command
borg create --stats ::backup-name /home/user
```

Key features:

- Deduplication to minimize storage requirements
- Compression to reduce backup size
- Fast local recovery from local repository
- Remote repository for disaster recovery

## B2 Cloud Storage Integration

Backblaze B2 provides affordable, reliable cloud storage:

- Cost-effective: $0.005/GB/month storage costs
- Lifecycle rules to manage older backups
- Application keys with limited permissions
- Multiple buckets for separation of backup types

## Combined System Benefits

Using both Duplicity and Borg provides several advantages:

1. **Different backup formats**: Protection against tool-specific issues
2. **Complementary features**: Encryption from Duplicity, deduplication from Borg
3. **Multiple recovery options**: Choose the most appropriate for each situation
4. **System redundancy**: If one system fails, the other still provides protection

## Monitoring and Maintenance

Regular monitoring ensures backup integrity:

- Daily email reports of backup status
- Weekly verification of backup integrity
- Monthly test restores
- Quarterly system review and optimization

[Back to Overview]({{ site.baseurl }}/backup-strategy/)

