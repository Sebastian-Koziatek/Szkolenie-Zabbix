#!/bin/bash

# Sprawdzenie, czy skrypt jest uruchomiony z uprawnieniami root
if [ "$EUID" -ne 0 ]; then
  echo "Proszę uruchomić ten skrypt jako root."
  exit 1
fi

echo "Pobieranie pakietu Zabbix..."
wget https://repo.zabbix.com/zabbix/6.4/ubuntu-arm64/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu24.04_all.deb

if [ $? -ne 0 ]; then
  echo "Błąd podczas pobierania pakietu. Sprawdź połączenie z internetem."
  exit 1
fi

echo "Instalowanie pakietu Zabbix..."
dpkg -i zabbix-release_latest+ubuntu24.04_all.deb

if [ $? -ne 0 ]; then
  echo "Błąd podczas instalacji pakietu. Sprawdź wymagania i spróbuj ponownie."
  exit 1
fi

echo "Aktualizacja listy pakietów..."
apt update

if [ $? -ne 0 ]; then
  echo "Błąd podczas aktualizacji listy pakietów. Sprawdź konfigurację repozytoriów."
  exit 1
fi

echo "Instalowanie agenta Zabbix..."
apt install -y zabbix-agent

if [ $? -ne 0 ]; then
  echo "Błąd podczas instalacji agenta Zabbix. Sprawdź logi."
  exit 1
fi

echo "Otwieranie pliku konfiguracyjnego w edytorze nano..."
nano /etc/zabbix/zabbix_agentd.conf
