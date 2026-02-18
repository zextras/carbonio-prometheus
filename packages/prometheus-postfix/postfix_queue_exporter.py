#!/usr/bin/env python3
"""
Postfix Queue Statistics Prometheus Exporter
Uses the official prometheus_client library for proper metric exposition
"""

import json
import re
import subprocess
import time
import logging
from prometheus_client import start_http_server, Gauge, Info
from prometheus_client.core import GaugeMetricFamily, REGISTRY

# Configuration
LISTEN_ADDRESS = '0.0.0.0'
LISTEN_PORT = 9154
POSTQUEUE_PATH = '/opt/zextras/common/sbin/postqueue'
SCRAPE_TIMEOUT = 30  # seconds

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('postfix_exporter')


class PostfixQueueCollector:
    """
    Custom collector for Postfix queue statistics.
    Implements the Prometheus collector interface for on-demand metric collection.
    """

    def __init__(self):
        self.queue_types = ['corrupt', 'incoming', 'deferred', 'active', 'hold']

    def get_queue_counts(self):
        """Get mail queue count stats using postqueue -j"""
        queue_counts = {queue: 0 for queue in self.queue_types}

        try:
            result = subprocess.run(
                ['/usr/bin/sudo', POSTQUEUE_PATH, '-j'],
                capture_output=True,
                text=True,
                timeout=SCRAPE_TIMEOUT
            )

            if result.returncode == 0 and result.stdout:
                for line in result.stdout.strip().split('\n'):
                    if line:
                        try:
                            queue_item = json.loads(line)
                            queue_name = queue_item.get('queue_name', '')
                            if queue_name in queue_counts:
                                queue_counts[queue_name] += 1
                        except json.JSONDecodeError:
                            logger.warning(f"Failed to parse JSON line: {line}")
                            continue
        except subprocess.TimeoutExpired:
            logger.error("postqueue -j command timed out")
        except FileNotFoundError:
            logger.error(f"postqueue command not found at {POSTQUEUE_PATH}")
        except Exception as e:
            logger.error(f"Error getting queue counts: {e}")

        return queue_counts

    def get_queue_size(self):
        """Get mail queue size stats using postqueue -p"""
        size_kb = 0
        requests = 0

        try:
            result = subprocess.run(
                ['/usr/bin/sudo', POSTQUEUE_PATH, '-p'],
                capture_output=True,
                text=True,
                timeout=SCRAPE_TIMEOUT
            )

            if result.returncode == 0 and result.stdout:
                lines = result.stdout.strip().split('\n')
                if lines:
                    last_line = lines[-1]

                    # Parse: "-- 1234 Kbytes in 56 Request(s)."
                    match = re.search(r'(\d+)\s+Kbytes\s+in\s+(\d+)\s+Request', last_line)
                    if match:
                        size_kb = int(match.group(1))
                        requests = int(match.group(2))
        except subprocess.TimeoutExpired:
            logger.error("postqueue -p command timed out")
        except FileNotFoundError:
            logger.error(f"postqueue command not found at {POSTQUEUE_PATH}")
        except Exception as e:
            logger.error(f"Error getting queue size: {e}")

        return size_kb, requests

    def collect(self):
        """
        Collect metrics. This method is called by prometheus_client on each scrape.
        Yields metric families.
        """
        # Queue count metrics with labels
        queue_stat = GaugeMetricFamily(
            'postfix_queue_stat',
            'Number of messages in each Postfix queue',
            labels=['queue']
        )

        queue_counts = self.get_queue_counts()
        for queue_name, count in queue_counts.items():
            queue_stat.add_metric([queue_name], count)

        yield queue_stat

        # Queue size metrics
        size_kb, requests = self.get_queue_size()

        queue_size = GaugeMetricFamily(
            'postfix_queue_stat_size',
            'Total size of Postfix mail queue in Kbytes'
        )
        queue_size.add_metric([], size_kb)
        yield queue_size

        queue_requests = GaugeMetricFamily(
            'postfix_queue_stat_requests',
            'Total number of messages in Postfix mail queue'
        )
        queue_requests.add_metric([], requests)
        yield queue_requests

        # Timestamp metric (in milliseconds)
        timestamp = GaugeMetricFamily(
            'postfix_last_extraction_timestamp',
            'Unix timestamp in milliseconds of last metric collection'
        )
        timestamp.add_metric([], int(time.time() * 1000))
        yield timestamp


class PostfixExporter:
    """Main exporter class"""

    def __init__(self, port=LISTEN_PORT, address=LISTEN_ADDRESS):
        self.port = port
        self.address = address

        # Register custom collector
        REGISTRY.register(PostfixQueueCollector())

        # Add exporter info
        self.exporter_info = Info('postfix_exporter', 'Postfix Queue Statistics Exporter')
        self.exporter_info.info({
            'version': '2.0.0',
            'postqueue_path': POSTQUEUE_PATH,
        })

        # Add up metric to track exporter availability
        self.up_metric = Gauge(
            'postfix_exporter_up',
            'Postfix exporter is running'
        )
        self.up_metric.set(1)

    def run(self):
        """Start the HTTP server"""
        try:
            start_http_server(self.port, addr=self.address)
            logger.info(f"Postfix Queue Exporter started on {self.address}:{self.port}")
            logger.info(f"Metrics available at http://{self.address}:{self.port}/metrics")

            # Keep the server running
            while True:
                time.sleep(1)

        except OSError as e:
            if "Address already in use" in str(e):
                logger.error(f"Port {self.port} is already in use.")
            else:
                logger.error(f"Failed to start HTTP server: {e}")
            raise
        except KeyboardInterrupt:
            logger.info("Shutting down exporter")
            self.up_metric.set(0)
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            self.up_metric.set(0)
            raise


def main():
    """Main entry point"""
    logger.info("Starting Postfix Queue Prometheus Exporter")
    logger.info(f"Configuration: {LISTEN_ADDRESS}:{LISTEN_PORT}")
    logger.info(f"Postqueue path: {POSTQUEUE_PATH}")

    exporter = PostfixExporter(port=LISTEN_PORT, address=LISTEN_ADDRESS)
    exporter.run()


if __name__ == '__main__':
    main()