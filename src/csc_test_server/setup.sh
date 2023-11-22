#!/usr/bin/env bash
sudo cp tcp_server.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable tcp_server.service
sudo systemctl start tcp_server.service

