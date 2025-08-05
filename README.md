# LaTeX-Klasse zur Erstellung eines Wochenstundenplans

Die LaTeX-Klasse `stundenplan.cls` erzeugt eine übersichtliche und optisch
ansprechende Darstellung eines Wochenstundenplans mit farbigen Boxen, flexibler
Zeitskala und konfigurierbaren Wochentagen.

Sie eignet sich insbesondere für Studiengangsübersichten,
Lehrveranstaltungspläne oder Veranstaltungsraster im Hochschulkontext.

## Voraussetzungen

* LuaLaTeX oder XeLaTeX (wegen `fontspec`, Unicode und Farben)
* Pakete: `tikz`, `tabularray`, `fontawesome5`, `csvsimple`, `microtype`,
  `polyglossia`, `xstring`

## Nutzung

### Termine

Ein Termin wird mit einem Makro wie `\eventA`, `\eventB`, etc. erstellt:

```latex
\eventA{<Titel>}{<Raum>}{<Tag>}{<Startzeit>}{<Endzeit>}
```

Beispiel:

```latex
\eventA{Software-Technik \&\\ Software Engineering}{S 01.213}{Mo}{14:00}{15:30}
```

### Farbstile

Es sind bereits standardmäßig Farbtöne für fünf Hauptereignisse (z.B. "Vorlesung
Software Engineering") plus fünf zugehörigen Nebenereignissen (z.B. "Labor
Software Engineering") vorgegeben:

| Makro             | Typ                | Farbe       |
|-------------------|--------------------|-------------|
| `\eventA`         | Haupttermin A      | Blau        |
| `\eventAalt`      | Nebentermin A      | Hellblau    |
| `\eventB`         | Haupttermin B      | Grün        |
| `\eventBalt`      | Nebentermin B      | Hellgrün    |
| `\eventC`         | Haupttermin C      | Braun       |
| `\eventCalt`      | Nebentermin C      | Hellbraun   |
| `\eventD`         | Haupttermin D      | Rot         |
| `\eventDalt`      | Nebentermin D      | Hellrot     |
| `\eventGeneric`   | Generischer Termin | Grau        |
| `\eventGenericAlt`| Variante           | Hellgrau    |


### Hinweise

* Zeitangaben wie "15:45" müssen im Format `HH:MM` übergeben werden.
* Leere Räume können mit `{}` übergeben werden.
* Die Box-Inhalte werden automatisch formatiert (fett für Titel, Icons für Raum
  und Uhrzeit).

## Konfigurationsparameter

Die folgenden Konfigurationsparameter bestimmen die Darstellung des
Stundenplans:

* `\spSetHeadline{Wintersemester 2025/26}`  
  Legt die Überschrift des Stundenplans fest.

* `\spSetStartTime{8}`  
  Setzt die Startzeit des Stundenplans in vollen Stunden (Dezimalzahl).  
  Beispiel: `8` entspricht 08:00 Uhr.

* `\spSetEndTime{19}`  
  Setzt die Endzeit des Stundenplans in vollen Stunden (Dezimalzahl).  
  Beispiel: `19` entspricht 19:00 Uhr.

* `\spSetGranularity{15}`  
  Definiert die zeitliche Auflösung der Rasterung in Minuten.  
  Beispiel: `15` ergibt ein 15-Minuten-Raster.

* `\spSetDays{Mo,Di,Mi,Do,Fr}`  
  Legt die Wochentage fest, die im Stundenplan dargestellt werden.  
  Zulässig sind deutsche und englische Abkürzungen:  
  `Mo, Di, Tu, Mi, We, Do, Th, Fr, Sa, So, Su`.

* `\spSetSlotHeight{0.32}`  
  Legt die Höhe eines Zeitslots entsprechend der Granularität in **cm** fest.  
  Beispiel: Bei 15 Minuten Raster ergibt `0.32` cm pro Slot.

* `\spSetDayWidth{5}`  
  Definiert die Breite einer einzelnen Tagesspalte in **cm**.

* `\spSetEventMargin{0.05}`  
  Legt den Abstand (*Margin*) zwischen den farbigen Event-Kästen und den  
  Begrenzungen der Spalte (horizontal) bzw. des Zeitrasters (vertikal) fest –  
  also den äußeren Abstand der Boxen.

## Einschränkungen

Gleichzeitig stattfindende Termine werden aktuell übereinander gezeichnet,
sodass spätere Einträge frühere überlagern.

## Beispiel

Die folgende Datei erzeugt einen beispielhaften Stundenplan für das
Wintersemester 2025/26. Sie zeigt, wie die Event-Makros (\eventA, \eventB, ...)
verwendet werden können:

```latex
\documentclass{stundenplan}

\spSetStartTime{8}  % Früheste Uhrzeit
\spSetEndTime{19}   % Späteste Uhrzeit
\spSetHeadline{Wintersemester 2025/26}

\begin{document}

\begin{stundenplan}

% Software Engineering als Typ A (blau/hellblau)
\eventA{Software-Technik \&\\ Software Engineering}{S 01.213}{Mo}{14:00}{15:30}
\eventA{Software-Technik \&\\ Software Engineering}{S 07.210}{Di}{15:45}{17:15}
\eventAalt{Labor Software-Technik \&\\ Software Engineering}{S 07.210}{Di}{17:30}{19:00}

% Informatik 2 als Typ B (grün/hellgrün)
\eventB{Informatik 2}{S 01.007}{Mo}{15:45}{17:15}
\eventB{Informatik 2}{S 01.006}{Di}{11:30}{13:00}
\eventBalt{Labor Informatik 2}{S 07.001}{Mo}{9:45}{11:15}

% ASM als Typ D (rot) – könnte auch Typ C oder Generic sein
\eventD{ASM Software Engineering}{S 07.101}{Do}{14:00}{15:30}
\eventD{ASM Software Engineering}{S 07.101}{Do}{15:45}{17:15}

% Meetings als generische Events (grau)
\eventGeneric{Dekanats JF}{}{Mi}{12:00}{13:00}
\eventGeneric{Fakultätsrat}{}{Mi}{14:30}{17:00}
\eventGeneric{Industriekolloquium}{}{Mi}{17:00}{18:00}

\end{stundenplan}

\end{document}
```

### Hinweise

* Die Klassen-Datei stundenplan.cls muss sich im gleichen Verzeichnis befinden
  oder korrekt eingebunden sein.
* Die Datei kann z. B. mit lualatex kompiliert werden:

```bash
$ lualatex stundenplan-25w.tex
```
