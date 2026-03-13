# Prototyp prototypu alpha wersji 0.1 AWARE

Ten dokument definiuje zasady pracy nad wspólną bazą kodu.

Proszę o przeczytanie tego dokumentu i przestrzeganie
regulaminu przed wysyłaniem czegokolwiek do repozytorium.

Będę sprawdzać pull requesty pod kątem zgodzności z tym dokumentem.

## Struktura folderów

Nie bez powodu narobiłem tyle folderów i podfolderów.
Ma być porządek, żeby się kula nie przyczepił.

```
AWARE_v0
├── assets
│   └── svg
│       ├── icon.svg
│       └── icon.svg.import
├── project.godot
├── README.md
├── scenes
│   └── levels
└── src
    ├── core
    ├── camera
    ├── player
    ├── lib
    └── scripts
```

## Skrypty i klasy

Skrypty samych poziomów lub postaci idą do `src/scripts`,
nazwane tak samo jak Node do którego są podpięte.

Skrypty używane częściej, z jakimiś
helperami/bibliotekami/funkcjami/klasami idą do `src/lib`.

GDScript jest językiem obiektowym.

**UŻYWAJCIE GO JAK JĘZYKA OBIEKTOWEGO.**

## Commity gita

Zalecałbym zapoznanie się ze standardem *conventional commits*.

[https://www.conventionalcommits.org/en/v1.0.0/](https://www.conventionalcommits.org/en/v1.0.0/)

Piszemy wiadomości commitów rzecz jasna po angielsku.

Dozwolone wiadomości commitów (przykłady oczywiście):

- `feat(src/scripts): Added script for component drag-and-drop`
- `fix(src/lib): Fixed the pathfinding procedure`
- `chore(assets/ico): Converted icons to .ico format`

NIEdozwolone wiadomości commitów:

- `feat: Updated something`
- `.`
- `Added more icons to assets/png`
- `trzymaj jakiś kodzik`
- `Added files via upload`

Prosiłbym o commitowanie regularnie, aby historia zmian była czytelna.

Każda zmiana która coś dodała lub naprawiła (o ile działa :3)
powinna być zaraz commitowana i pushowana.
