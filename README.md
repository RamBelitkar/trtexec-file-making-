Sir, here is the complete flow from `aws configure` to creating and connecting to a free-tier EC2 instance using AWS CLI.

---

# 1. Configure AWS CLI

Run:

```bash id="1fjlwm"
aws configure
```

Enter:

```text id="jlwm34"
AWS Access Key ID: YOUR_ACCESS_KEY
AWS Secret Access Key: YOUR_SECRET_KEY
Default region name: ap-south-1
Default output format: json
```

---

# 2. Verify AWS Login

```bash id="jlwm29"
aws sts get-caller-identity
```

If successful, AWS CLI is ready.

---

# 3. Create SSH Key Pair

This is needed to login to EC2.

```bash id="jlwm52"
aws ec2 create-key-pair \
--key-name my-key \
--query 'KeyMaterial' \
--output text > my-key.pem
```

Secure the key:

```bash id="jlwm94"
chmod 400 my-key.pem
```

---

# 4. Create Security Group

```bash id="jlwm66"
aws ec2 create-security-group \
--group-name my-sg \
--description "My EC2 security group"
```

You will get output like:

```json id="jlwm76"
{
  "GroupId": "sg-0123456789abcdef0"
}
```

Copy the `GroupId`.

---

# 5. Allow SSH Access (Port 22)

Replace `sg-xxxxxxxx` with your actual GroupId.

```bash id="jlwm15"
aws ec2 authorize-security-group-ingress \
--group-id sg-xxxxxxxx \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0
```

---

# 6. Get Ubuntu Free-Tier AMI

Run:

```bash id="jlwm63"
aws ec2 describe-images \
--owners 099720109477 \
--filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
--query 'Images[*].[ImageId,Name]' \
--output table
```

Copy one AMI ID.

Example:

```text id="jlwm71"
ami-0abcdef1234567890
```

---

# 7. Launch Free-Tier EC2 Instance

Replace:

* `ami-xxxxxxxx`
* `sg-xxxxxxxx`

Run:

```bash id="jlwm31"
aws ec2 run-instances \
--image-id ami-xxxxxxxx \
--count 1 \
--instance-type t2.micro \
--key-name my-key \
--security-group-ids sg-xxxxxxxx \
--block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":8}}]' \
--tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=FreeTierServer}]'
```

This creates:

* free-tier EC2
* 8GB disk
* SSH access

---

# 8. Check Instance Status

```bash id="jlwm22"
aws ec2 describe-instances \
--query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
--output table
```

Wait until state becomes:

```text id="jlwm62"
running
```

Copy the Public IP.

---

# 9. Connect to EC2

For Ubuntu:

```bash id="jlwm84"
ssh -i my-key.pem ubuntu@PUBLIC_IP
```

Example:

```bash id="jlwm81"
ssh -i my-key.pem ubuntu@13.233.xxx.xxx
```

---

# 10. Update EC2 Machine

Inside EC2:

```bash id="jlwm47"
sudo apt update && sudo apt upgrade -y
```

---

# 11. Stop Instance When Not Using (Important)

To avoid charges:

## Stop

```bash id="jlwm90"
aws ec2 stop-instances --instance-ids i-xxxxxxxx
```

## Terminate Permanently

```bash id="jlwm95"
aws ec2 terminate-instances --instance-ids i-xxxxxxxx
```

---

# Important Free Tier Notes

Stay within:

* `t2.micro` or `t3.micro`
* 30GB storage total
* 1–2 small instances

Avoid:

* GPU instances
* Elastic Load Balancer
* NAT Gateway
* Large EBS disks

---

# Quick One-Line Flow

```bash id="jlwm18"
aws configure
aws ec2 create-key-pair ...
aws ec2 create-security-group ...
aws ec2 run-instances ...
ssh -i my-key.pem ubuntu@IP
```
