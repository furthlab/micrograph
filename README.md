# Micrograph Extension For Quarto

Quarto shortcode extension to display micrographs in revealjs presentations

## Installing

```bash
quarto add furthlab/micrograph
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

- First argument is path to file.
- Second argument is name of the blue channel (default `DAPI`).
- Third argument is name of the green channel (default `Phalloidin`).
- Fourth argument is name of the red channel (default `anti-FLAG`).
- Optional arguments are:
    - `width = "255"` default is 255px. 

```
{{< micrograph ./img/GFP.jpg DAPI Phalloidin GFP width="255" >}}
```

## Example

Check our the source code for a minimal example using revealjs for the presentation: [example.qmd](example.qmd).

