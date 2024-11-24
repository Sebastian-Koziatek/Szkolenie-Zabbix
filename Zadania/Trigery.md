# Zadania Zabbix - Monitoring systemu

## Zadanie 1: Wykrywanie wysokiego obciążenia CPU
**Cel**: Skonfigurowanie triggera, który wyświetli alarm, gdy obciążenie CPU przekroczy 80% przez 1 minutę.

### Kroki:
1. Utwórz element danych (item) typu `system.cpu.util[,user]` dla hosta.
2. Stwórz trigger z wyrażeniem:

```
last(/Docker_server/system.cpu.util,#1)>1
```
3. Zweryfikuj, czy alarm pojawia się przy wysokim obciążeniu CPU.

## Zadanie 2: Uprawnienia na pliku

**Cel**: Alarm ma się pojawić, gdy uprawnienia na wskazanym pliku będą 777.

### Kroki:
1. Utwórz element danych `vfs.file.permissions[/var/testowy1.txt]` dla pliku `testowy1.txt` 
2. Skonfiguruj trigger z wyrażeniem:

```plaintext
last(/Docker_server/vfs.file.permissions[/var/testowy1.txt])=777
```

3. Zmień uprawnienia na wskazanym pliku:
```bash
chmod 777 /var/testowy1.txt
```
---
## Zadanie 3: Pamięć swap wyczerpana

**Cel**: Ustaw trigger wykrywający brak wolnej pamięci swap.
### Kroki:

1. Utwórz element danych `icmpping` dla monitorowanego hosta.

2. Skonfiguruj trigger z wyrażeniem:
```plaintext
last(/Docker_server/system.swap.size[,free])<1
```
  
3. Wyłącz odpowiedź na ping na monitorowanym hoście i sprawdź, czy trigger działa.

  

--- 
## Zadanie 4: Wykrywanie czasu działania hosta (uptime) poniżej określonego progu

**Cel**: Alarm pojawia się, gdy czas działania (uptime) jest krótszy niż 700min minut (np. po restarcie).
### Kroki:

1. Edytuj istniejący wyzwalacz `last(/Docker_server/system.uptime)<10m`.

2. Stwórz trigger z wyrażeniem:
```plaintext
{host:system.uptime.last()}<600
```
3. Przetestuj przez restart monitorowanego hosta.

---
## Zadanie 5: Monitorowanie liczby procesów

**Cel**: Wyświetlenie alarmu, gdy liczba uruchomionych procesów przekroczy lub jest równa 1.
### Kroki:

1. Utwórz element danych `proc.num[]`.
2. Skonfiguruj trigger z wyrażeniem:
```plaintext
last(/Docker_server/proc.num[,,run])>=1
```
3. Przetestuj przez uruchomienie wielu procesów na monitorowanym systemie (np. pętli while).