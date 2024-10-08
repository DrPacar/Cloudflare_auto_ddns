# 🌐 Dynamic DNS Updater Script

Welcome to the **Dynamic DNS Updater Script**, a highly customizable and automated solution designed to keep your domain's `A` records up-to-date with your current public IP. This script leverages the power of **Cloudflare's API** to seamlessly update DNS records for multiple domains, ensuring that your domains are always pointed to the right IP address, no matter how frequently it changes.

## ✨ Key Features

- **Automated IP Detection:** Fetches the current public IP address using a simple curl request to ensure accuracy.
- **Multiple Domain Support:** Handles multiple domains effortlessly through an easy-to-extend domain array.
- **Secure API Integration:** Authenticates using **Cloudflare API tokens** with proper read and write permissions to manage DNS records.
- **Zone ID and Record Management:** Automatically fetches Zone IDs and existing DNS records, ensuring correct and efficient record updates.
- **Proxied and Non-Proxied DNS Records:** Preserves the proxied status of DNS records during updates, maintaining the configuration you've set in Cloudflare.
- **Fast and Quiet Execution:** With minimal output and smart checks, the script only updates DNS records when the IP has changed, reducing unnecessary API calls.

## ⚙️ How It Works

- **Fetch Public IP:** The script starts by fetching your current public IP from `ifconfig.me`.
- **Domain Loop:** Iterates over each domain listed in the script's domain array.
- **API Token Validation:** For each domain, it verifies the presence of a valid Cloudflare API token.
- **Zone ID Retrieval:** Fetches the Zone ID associated with the domain from the Cloudflare API.
- **DNS Record Updates:**
  - Retrieves all `A` records associated with the domain.
  - Compares each record's current IP with the fetched public IP.
  - If the IPs differ, the script updates the DNS record with the new IP.
  - If the IPs match, no update is performed.
- **Proxied Status Preservation:** Ensures that the DNS record's proxied status (Cloudflare Proxy) remains unchanged after updates.

## 🛠️ Requirements

- **Cloudflare Account:** You need an active Cloudflare account managing your domain's DNS settings.
- **Cloudflare API Token(s):** Ensure your API tokens have read and write access to DNS records.
- **jq:** The script uses `jq` to parse JSON responses from the Cloudflare API. Install it using your package manager:

```bash
sudo apt-get install jq # for Debian/Ubuntu
sudo yum install jq     # for CentOS/RHEL
```

## 🚀 Usage

1. **Clone the Repository:**

```bash
git clone https://github.com/your-repo/dynamic-dns-updater.git
cd dynamic-dns-updater
```

2. Configure Domains and API Tokens:

   - Open the script and replace `"YOUR DOMAIN"` with your actual domain.
   - Replace `"YOURTOKEN"` with the appropriate Cloudflare API token for each domain.

3. **Run the Script:** Make the script executable and run it:

```bash
chmod +x update-dns.sh
./update-dns.sh
```

4.  **Set Up a Cron Job (Optional):** To automate the process and run the script at regular intervals, add a cron job:

    ```bash
    crontab -e
    ```

    Add the following line to run the script every 5 minutes:

    ```
    */5 * * * * /path/to/update-dns.sh
    ```

## 📄 Example Configuration

In the script, configure your domains and API tokens as shown below:

```bash
DOMAINS=(
"example.com"
"anotherdomain.com"
)

declare -A API_TOKENS=(
["example.com"]="your-api-token-1"
["anotherdomain.com"]="your-api-token-2"
)
```

## 📜 License

This script is open-source and distributed under the MIT License. See the LICENSE file for more information.
