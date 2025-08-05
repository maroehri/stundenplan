\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{stundenplan}[2025/08/04 v1.0 Stundenplan Class]

% Basis-Klasse laden
\LoadClass[a4paper,landscape]{article}
\pagestyle{empty}

\RequirePackage[margin=1.5cm]{geometry}
\RequirePackage{polyglossia}
\RequirePackage{ellipsis}
\RequirePackage[
  expansion=true,
  protrusion=true,
  activate={true,nocompatibility},
  final,
  tracking=true
]{microtype}
\RequirePackage{tabularray}
\RequirePackage{fontawesome5}
\RequirePackage{xstring}
\RequirePackage{csvsimple}
\RequirePackage{xcolor}
\RequirePackage{fontspec}
\RequirePackage{tikz}
\RequirePackage{pgffor}
\RequirePackage{etoolbox}

\setmainlanguage{german}

\setsansfont{Lato}[Scale=0.9]
\renewcommand{\familydefault}{\sfdefault}

% HSE-Farben
\definecolor{hse-dunkelblau}{cmyk}{1,.7,.08,.54}
\definecolor{hse-rot}{cmyk}{.1,1,.7,0}
\definecolor{hse-hellblau}{cmyk}{.75,.1,.06,0}
\definecolor{hse-blau75}{HTML}{8abde2}
\definecolor{hse-blau50}{HTML}{b4d3ed}
\definecolor{hse-blau25}{HTML}{dbe9f7}
\definecolor{hse-blau15}{HTML}{eaf2fa}
\definecolor{hse-hellgrau}{cmyk}{0,0,0,.08}

% Graustufenpfalette
\definecolor{dunkelgrau}{gray}{0.7}
\definecolor{mittelgrau}{gray}{0.9}
\definecolor{hellgrau}{cmyk}{0,0,0,.08}
\definecolor{codebg}{cmyk}{0,0,0,.04}
\definecolor{weiss}{cmyk}{0,0,0,0}

% Pastell-Farbpalette
\definecolor{pastell-blau}{HTML}{4381a4}
\definecolor{pastell-gruen}{HTML}{48a9a6}
\definecolor{pastell-braun}{HTML}{d4b483}
\definecolor{pastell-rot}{HTML}{c1666b}
\definecolor{pastell-grau}{HTML}{e5dfda}

% Pastell-Tönungen
\definecolor{pastell-blau-tint}{HTML}{b6cbda}
\definecolor{pastell-gruen-tint}{HTML}{badcdb}
\definecolor{pastell-braun-tint}{HTML}{efe0cc}
\definecolor{pastell-rot-tint}{HTML}{eac1c1}
\definecolor{pastell-grau-tint}{HTML}{f5f2f0}

% ==============================================
% KONFIGURATION MIT STANDARDWERTEN
% ==============================================
\newcommand{\spSetStartTime}[1]{\def\sp@starttime{#1}}
\newcommand{\spSetEndTime}[1]{\def\sp@endtime{#1}}
\newcommand{\spSetGranularity}[1]{\def\sp@granularity{#1}}
\newcommand{\spSetSlotHeight}[1]{\def\sp@slotheight{#1}}
\newcommand{\spSetEventMargin}[1]{\def\sp@eventmargin{#1}}
\newcommand{\spSetDayWidth}[1]{\def\sp@daywidth{#1}}
\newcommand{\spSetDays}[1]{\def\sp@days{#1}}
\newcommand{\spSetHeadline}[1]{\def\sp@headline{#1}}

% Standardwerte setzen
\spSetStartTime{8}
\spSetEndTime{19}
\spSetGranularity{15}
\spSetSlotHeight{0.32}
\spSetEventMargin{0.05}
\spSetDayWidth{5}
\spSetDays{Mo,Di,Mi,Do,Fr}
\spSetHeadline{Wintersemester 2025/26}

% ==============================================
% INTERNE HILFSMAKROS
% ==============================================

% Wochentag-zu-Index-Konvertierung
\newcommand{\sp@daytoindex}[1]{%
  \ifstrequal{#1}{Mo}{\def\dayindex{0}}{%
  \ifstrequal{#1}{Di}{\def\dayindex{1}}{%
  \ifstrequal{#1}{Tu}{\def\dayindex{1}}{%
  \ifstrequal{#1}{Mi}{\def\dayindex{2}}{%
  \ifstrequal{#1}{We}{\def\dayindex{2}}{%
  \ifstrequal{#1}{Do}{\def\dayindex{3}}{%
  \ifstrequal{#1}{Th}{\def\dayindex{3}}{%
  \ifstrequal{#1}{Fr}{\def\dayindex{4}}{%
  \ifstrequal{#1}{Sa}{\def\dayindex{5}}{%
  \ifstrequal{#1}{So}{\def\dayindex{6}}{%
  \ifstrequal{#1}{Su}{\def\dayindex{6}}{%
    \def\dayindex{0}% Fallback
  }}}}}}}}}}}%
}

% Zeit in Dezimalform zu "HH:MM" konvertieren
\newcommand{\sp@formattime}[1]{%
  \pgfmathsetmacro\hours{int(#1)}%
  \pgfmathsetmacro\minutes{int((#1-\hours)*60)}%
  \ifnum\minutes<10
    \hours:0\minutes%
  \else
    \hours:\minutes%
  \fi
}

% Zeitangabe als "HH:MM" in Dezimalzahl umrechnen
\newcommand{\sp@parseTime}[2]{%
  \StrBefore{#2}{:}[\tmphour]%
  \StrBehind{#2}{:}[\tmpminute]%
  \pgfmathsetmacro#1{\tmphour + \tmpminute/60}%
}

% ==============================================
% BENUTZER-API
% ==============================================

% Haupt Event-Makro
\newcommand{\event}[6]{%
  \sp@daytoindex{#4}% Konvertiert Wochentag-Abkürzung zu Index
  \pgfmathsetmacro\x{\dayindex*\sp@daywidth}
  \sp@parseTime{\startdecimal}{#5}%
  \sp@parseTime{\enddecimal}{#6}%
  \pgfmathparse{((\startdecimal-\sp@starttime)*60)/\sp@granularity*\sp@slotheight}
  \let\ytop\pgfmathresult
  \pgfmathparse{((\enddecimal-\sp@starttime)*60)/\sp@granularity*\sp@slotheight}
  \let\ybottom\pgfmathresult
  \pgfmathsetmacro\height{\ybottom - \ytop}

  % Stil-abhängige Farben - erweitert für Event-Paare
  \ifcase#1\relax
    % Typ 0:
    \def\fillcolor{pastell-blau}\def\textcolor{weiss}%
  \or
    % Typ 1:
    \def\fillcolor{pastell-blau-tint}\def\textcolor{hse-dunkelblau}%
  \or
    % Typ 2:
    \def\fillcolor{pastell-gruen}\def\textcolor{weiss}%
  \or
    % Typ 3:
    \def\fillcolor{pastell-gruen-tint}\def\textcolor{hse-dunkelblau}%
  \or
    % Typ 4:
    \def\fillcolor{pastell-braun}\def\textcolor{hse-dunkelblau}%
  \or
    % Typ 5:
    \def\fillcolor{pastell-braun-tint}\def\textcolor{hse-dunkelblau}%
  \or
    % Typ 6:
    \def\fillcolor{pastell-rot}\def\textcolor{weiss}%
  \or
    % Typ 7:
    \def\fillcolor{pastell-rot-tint}\def\textcolor{hse-dunkelblau}%
  \or
    % Typ 8:
    \def\fillcolor{pastell-grau}\def\textcolor{hse-dunkelblau}%
  \or
    % Typ 9:
    \def\fillcolor{pastell-grau-tint}\def\textcolor{hse-dunkelblau}%
  \else
    % Fallback: Standard blau
    \def\fillcolor{hse-dunkelblau}\def\textcolor{weiss}%
  \fi

  % Berechne abgerückte Koordinaten
  \pgfmathsetmacro\eventx{\x + \sp@eventmargin}
  \pgfmathsetmacro\eventwidth{\sp@daywidth - 2*\sp@eventmargin}
  \pgfmathsetmacro\eventy{\ytop + \sp@eventmargin}
  \pgfmathsetmacro\eventheight{\height - 2*\sp@eventmargin}

  % Event zeichnen mit Abrundung
  \draw[fill=\fillcolor, draw=none, rounded corners=3pt]
    (\eventx, -\eventy) rectangle ++(\eventwidth, -\eventheight);

  % Zusätzlicher Abstand zum linken Rand (in cm)
  \def\leftpadding{0.15}

  % Text zusammensetzen und platzieren - linksbündig mit Abstand
  \ifx\relax#3\relax% Kein Raum angegeben
    \node[anchor=west, text=\textcolor] at ({\eventx + \leftpadding}, {-(\eventy + \eventheight/2)}) {%
      \begin{tblr}{
        colspec = {Q[c,m,wd=0.4cm] Q[l,m]},
        stretch=0.25,
        colsep=0.1cm
      }
        \SetCell[c=2]{l} {\normalsize\bfseries #2} & \\
        \small \faClock[regular] & \small #5--#6
      \end{tblr}
    };
  \else% Raum angegeben
    \node[anchor=west, text=\textcolor] at ({\eventx + \leftpadding}, {-(\eventy + \eventheight/2)}) {%
      \begin{tblr}{
        colspec = {Q[c,m,wd=0.4cm] Q[l,m]},
        stretch=0.25,
        colsep=0.1cm
      }
        \SetCell[c=2]{l} {\normalsize\bfseries #2} & \\
        \small \faMapMarker* & \small #3 \\
        \small \faClock[regular] & \small #5--#6
      \end{tblr}
    };
  \fi
}

% ==============================================
% EVENT-TYPEN (A, B, C, D für Hauptfarben + Alt-Varianten)
% ==============================================

% Event-Makros mit festen Farbzuordnungen
% Typ A: Blau
\newcommand{\eventA}[5]{\event{0}{#1}{#2}{#3}{#4}{#5}}      % Hauptfarbe blau
\newcommand{\eventAalt}[5]{\event{1}{#1}{#2}{#3}{#4}{#5}}   % Nebenfarbe hellblau

% Typ B: Grün
\newcommand{\eventB}[5]{\event{2}{#1}{#2}{#3}{#4}{#5}}      % Hauptfarbe grün
\newcommand{\eventBalt}[5]{\event{3}{#1}{#2}{#3}{#4}{#5}}   % Nebenfarbe hellgrün

% Typ C: Braun
\newcommand{\eventC}[5]{\event{4}{#1}{#2}{#3}{#4}{#5}}      % Hauptfarbe braun
\newcommand{\eventCalt}[5]{\event{5}{#1}{#2}{#3}{#4}{#5}}   % Nebenfarbe hellbraun

% Typ D: Rot
\newcommand{\eventD}[5]{\event{6}{#1}{#2}{#3}{#4}{#5}}      % Hauptfarbe rot
\newcommand{\eventDalt}[5]{\event{7}{#1}{#2}{#3}{#4}{#5}}   % Nebenfarbe hellrot

% Generische Events:
\newcommand{\eventGeneric}[5]{\event{8}{#1}{#2}{#3}{#4}{#5}}     % Hauptfarbe grau
\newcommand{\eventGenericAlt}[5]{\event{9}{#1}{#2}{#3}{#4}{#5}} % Nebenfarbe hellgrau

% ==============================================
% STUNDENPLAN-UMGEBUNG
% ==============================================
\newenvironment{stundenplan}{%
  \pagestyle{empty}
  \centering
  \vspace*{0.5cm}
  {\LARGE\bfseries \sp@headline{} \par}
  \vspace{0.5cm}

  \begin{tikzpicture}[font=\sffamily, scale=1]

  % Tagesanzahl berechnen
  \newcount\daycount \daycount=0
  \foreach \d in \sp@days { \advance\daycount by 1 }
  \pgfmathsetmacro{\centerx}{0.5*\sp@daywidth*\the\daycount}

  % Wochentage zentriert über Spalten
  \foreach [count=\i from 0] \day in \sp@days {
    \node[anchor=south] at ({(\i+0.5)*\sp@daywidth}, 0.3) {\textbf{\day}};
  }

  % Spaltenhintergrundfarben (abwechselnd hellgrau und weiß)
  \foreach [count=\i from 0] \day in \sp@days {
    \ifodd\i
      \def\bgcolor{white}
    \else
      \def\bgcolor{hellgrau}
    \fi
    \pgfmathsetmacro\ybottom{-\sp@slotheight*(\sp@endtime - \sp@starttime)*4}
    \draw[fill=\bgcolor, draw=none]
      ({\i*\sp@daywidth}, 0) rectangle ++(\sp@daywidth, \ybottom);
  }

  % Zeitraster + horizontale Linien
  \pgfmathsetmacro{\totalminutes}{(\sp@endtime - \sp@starttime)*60}

  % Feine horizontale Linien ohne Beschriftung
  \foreach \t in {15,30,...,\totalminutes} {
    \pgfmathsetmacro\y{\t/\sp@granularity*\sp@slotheight}
    \draw[gray!20] (0, -\y) -- ({5*\sp@daywidth}, -\y);
  }

  % Nur volle Stunden mit Beschriftung
  \foreach \t in {0,60,...,\totalminutes} {
    \pgfmathsetmacro\y{\t/\sp@granularity*\sp@slotheight}
    \pgfmathsetmacro\timevalue{\sp@starttime + \t/60}
    \node[anchor=east, text=black, font=\normalfont] at (0, -\y) {\sp@formattime{\timevalue}};
    \draw[black] (0, -\y) -- ({5*\sp@daywidth}, -\y);
  }

  % Vertikale Linien
  \foreach \i in {0,...,5} {
    \draw[gray!30] ({\i*\sp@daywidth}, 0) -- ({\i*\sp@daywidth}, {-\sp@slotheight*(\sp@endtime-\sp@starttime)*4});
  }
}{%
  \end{tikzpicture}
}
