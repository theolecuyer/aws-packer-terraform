#!/bin/bash
systemctl start docker
until docker info >/dev/null 2>&1; do sleep 2; done

mkdir -p /etc/prometheus
mkdir -p /etc/grafana/provisioning/datasources
mkdir -p /etc/grafana/provisioning/dashboards
mkdir -p /var/lib/grafana/dashboards

cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node_exporter'
    static_configs:
      - targets:
%{ for ip in all_targets ~}
          - '${ip}:9100'
%{ endfor ~}
EOF

cat > /etc/grafana/provisioning/datasources/prometheus.yaml << 'EOF'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
EOF

cat > /etc/grafana/provisioning/dashboards/default.yaml << 'EOF'
apiVersion: 1
providers:
  - name: default
    type: file
    options:
      path: /var/lib/grafana/dashboards
EOF

until curl -sL https://grafana.com/api/dashboards/1860/revisions/latest/download \
  -o /var/lib/grafana/dashboards/node-exporter.json; do sleep 10; done
sed -i 's/$${DS_PROMETHEUS}/Prometheus/g' /var/lib/grafana/dashboards/node-exporter.json

until docker run -d \
  --name prometheus \
  --restart always \
  --network host \
  -v /etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro \
  prom/prometheus; do sleep 10; done

until docker run -d \
  --name grafana \
  --restart always \
  --network host \
  -v /etc/grafana/provisioning:/etc/grafana/provisioning \
  -v /var/lib/grafana/dashboards:/var/lib/grafana/dashboards \
  -e GF_SECURITY_ADMIN_PASSWORD=${grafana_admin_password} \
  grafana/grafana; do sleep 10; done
