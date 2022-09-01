from pathlib import Path
from Bio import AlignIO
import typer

def alignment_html(
    alignment: Path = typer.Argument(..., help="The path to the tree file in newick format."),
):
    alignment = AlignIO.read(alignment, "fasta")
    indent = "  "
    print(alignment.get_alignment_length())
    print('<table class="table table-sm">')
    print(f'{indent}<thead>')
    print(f'{indent}{indent}<th scope="col">Seq ID</th>')
    print(f'{indent}</thead>')
    # print(alignment)
    print('</table>')



if __name__ == "__main__":
    typer.run(alignment_html)
