import re
import csv
from Bio import Phylo
import typer

def dates_from_tree(treefile:str, outfile:str):
    """
    Parses dates from the names of tips in a tree (expressed in Newick format) and outputs them as a CSV file.

    Dates must be in decimal years (at the end of the name) or as YYYY-MM-DD.

    Args:
        treefile (str): The path to a Newick file where date strings are embedded in the names of the tips
        outfile (str): A path to where the function should write a CSV output file with names of the tips as one column and date as another column.
    """
    tree = Phylo.read(treefile, "newick")
    pattern_strings = [
        r"\d{4}\.?\d*$",
        r"\d{4}-\d{2}-\d{2}",
    ]
    patterns = [re.compile(pattern_string) for pattern_string in pattern_strings]
    with open(outfile, 'w') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quoting=csv.QUOTE_MINIMAL)
        writer.writerow(['name', 'date'])    
        for node in tree.find_elements(terminal=True):
            for pattern in patterns:
                match = pattern.search(node.name)
                if match:
                    writer.writerow([node.name, match.group(0)])    
                    break


if __name__ == "__main__":
    typer.run(dates_from_tree)
