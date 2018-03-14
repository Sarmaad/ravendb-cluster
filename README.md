# ravendb-cluster
Easiest way to setup a RavenDB Cluster on Linux.

## Supported Distros:
- Ubunto 16.x

## How to use
First, read the blog post and watch the video to see the process end to end. link coming

### tl;dr
- upload your cert to box
- git clone the repository
- chmod +x DISTRO/install.sh
- DISTRO/install.sh subdomain.domain.com certificate_file_with_path certificate_password
- echo "IP_ADDRESS subdomain.domain.com" >> /etc/hosts
- systemcrl start ravendb

## Feedback
let me know if you come across any issues or any ideas for improvement. Open an issue! 

PRs are welcome.
