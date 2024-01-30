import jsonschema
import requests
import typer
import yaml
from pathlib import Path

app = typer.Typer()


@app.command()
def validate(
    yaml_file: Path = typer.Option(
        ...,
        "-y",
        "--yaml-file",
        exists=True,
        file_okay=True,
        dir_okay=False,
        readable=True,
        resolve_path=True,
        help="Path to the YAML file.",
    ),
    schema_url: str = typer.Option(
        "https://raw.githubusercontent.com/mskcc-omics-workflows/yaml_to_md/main/nextflow_schema/meta-schema.json",
        "--schema-url",
        "-s",
        help="URL of the JSON schema.",
    ),
):
    """
    The `validate` function validates a YAML data against a JSON schema retrieved from a given URL.

    :param yaml_file: The `yaml_file` parameter is the path to the YAML file that you want to convert to
    Markdown. It is specified using the `--yaml-file` or `-y` option when running the script. The file
    should exist and be readable

    :type yaml_file: Path

    :param schema_url: The `schema_url` parameter is a URL that points to a JSON schema file. This
    schema file defines the structure and validation rules for the YAML data
    """
    # read yaml file
    yaml_data = read_yaml(yaml_file)

    # Load YAML data
    data = yaml.safe_load(yaml_data)

    # Retrieve JSON schema from URL
    response = requests.get(schema_url)
    schema_data = response.json()

    # Validate YAML against schema

    try:
        jsonschema.validate(data, schema_data)
    except jsonschema.exceptions.ValidationError as err:
        typer.echo(
            "YAML could not be validated. Please check if its correct and follows the schema",
            err,
        )
        exit(1)
    typer.echo("YAML was successfully validated.")

    return data


@app.command()
def convert(
    yaml_file: Path = typer.Option(
        ...,
        "-y",
        "--yaml-file",
        exists=True,
        file_okay=True,
        dir_okay=False,
        readable=True,
        resolve_path=True,
        help="Path to the YAML file.",
    ),
    output_file: str = typer.Option(
        "output.md",
        "--output-file",
        "-o",
        help="Path to the output Markdown file.",
    ),
):
    """
    The `convert` function is a Python script that converts a YAML file into a Markdown file.

    :param yaml_file: The `yaml_file` parameter is the path to the YAML file that you want to convert to
    Markdown. It is specified using the `--yaml-file` or `-y` option when running the script. The file
    should exist and be readable

    :type yaml_file: Path

    :param output_file: The `output_file` parameter is the path to the output Markdown file. It
    specifies the file where the converted Markdown content will be saved. By default, the value is set
    to "output.md". However, you can provide a different file path if desired

    :type output_file: str
    """
    # Validate YAML against schema
    yaml_data = read_yaml(yaml_file)

    # Load YAML data
    data = yaml.safe_load(yaml_data)

    # Convert validated YAML to Markdown
    markdown_output = convert_yaml_to_markdown(data)

    # Write Markdown content to output file
    output_path = Path(output_file)
    output_path.write_text(markdown_output)

    typer.echo(f"Conversion completed. Markdown output saved to {output_path}.")

@app.command()
def all(
    yaml_file: Path = typer.Option(
        ...,
        "-y",
        "--yaml-file",
        exists=True,
        file_okay=True,
        dir_okay=False,
        readable=True,
        resolve_path=True,
        help="Path to the YAML file.",
    ),
    schema_url: str = typer.Option(
        "https://raw.githubusercontent.com/mskcc-omics-workflows/yaml_to_md/main/nextflow_schema/meta-schema.json",
        "--schema-url",
        "-s",
        help="URL of the JSON schema.",
    ),
    output_file: str = typer.Option(
        "output.md",
        "--output-file",
        "-o",
        help="Path to the output Markdown file.",
    ),
):
    """
    The `all` function is a Python script that validates and converts a YAML file into a Markdown file based on a
    specified JSON schema.

    :param yaml_file: The `yaml_file` parameter is the path to the YAML file that you want to convert to
    Markdown. It is specified using the `--yaml-file` or `-y` option when running the script. The file
    should exist and be readable

    :type yaml_file: Path

    :param schema_url: The `schema_url` parameter is the URL of the JSON schema that will be used to
    validate the YAML data. In this code, the default value for `schema_url` is set to "https://raw.githubusercontent.com/mskcc-omics-workflows/yaml_to_md/main/nextflow_schema/meta-schema.json" derived from
    "https://raw.githubusercontent.com/nf-core/modules/master/modules/meta-schema.json". However, you
    can provide one as well

    :type schema_url: str

    :param output_file: The `output_file` parameter is the path to the output Markdown file. It
    specifies the file where the converted Markdown content will be saved. By default, the value is set
    to "output.md". However, you can provide a different file path if desired

    :type output_file: str
    """
    # Validate YAML against schema
    validated_data = validate(yaml_file, schema_url)

    # Convert validated YAML to Markdown
    markdown_output = convert_yaml_to_markdown(validated_data)

    # Write Markdown content to output file
    output_path = Path(output_file)
    output_path.write_text(markdown_output)

    typer.echo(f"Conversion completed. Markdown output saved to {output_path}.")


def read_yaml(yaml_file):
    """
    The function `read_yaml` reads the contents of a YAML file and returns it as a string.

    :param yaml_file: The `yaml_file` parameter is a file object that represents a YAML file
    :return: the contents of the YAML file as a string.
    """
    return yaml_file.read_text()


def convert_yaml_to_markdown(data):
    """
    The `convert_yaml_to_markdown` function takes in a YAML data structure and converts it into a
    Markdown format.

    :param data: The `data` parameter is a dictionary that contains information about a module. It has
    the following structure:
    :return: a Markdown-formatted string that contains information about a module. The string includes
    the module's name, description, keywords, tools, inputs, outputs, authors, and maintainers.
    """
    # Create Markdown table for keywords
    keywords_table = "| Keywords |\n"
    keywords_table += "|----------|\n"
    for keyword in data["keywords"]:
        keyword_table_row = f"| {keyword} |\n"
        keywords_table += keyword_table_row

    # Create Markdown table for tools
    tools_table = "| Tool | Description | License | Homepage |\n"
    tools_table += "|------|-------------|---------|----------|\n"
    for tool in data["tools"]:
        tool_name = next(iter(tool))  # Get the tool name
        tool_description = tool[tool_name]["description"].replace("\n", " ")
        tool_license = ", ".join(tool[tool_name]["licence"]).replace("\n", " ")
        tool_homepage = tool[tool_name]["homepage"].replace("\n", " ")
        tool_table_row = (
            f"| {tool_name} | {tool_description} | {tool_license} | {tool_homepage} |\n"
        )
        tools_table += tool_table_row

    # Create Markdown table for inputs
    inputs_table = "| Input | Type | Description | Pattern |\n"
    inputs_table += "|-------|------|-------------|---------|\n"
    for input_item in data["input"]:
        input_name = next(iter(input_item))  # Get the input name
        input_type = input_item[input_name]["type"]
        input_description = input_item[input_name]["description"].replace("\n", " ")
        input_pattern = input_item[input_name].get("pattern", "").replace("\n", " ")
        input_table_row = (
            f"| {input_name} | {input_type} | {input_description} | {input_pattern} |\n"
        )
        inputs_table += input_table_row

    # Create Markdown table for outputs
    outputs_table = "| Output | Type | Description | Pattern |\n"
    outputs_table += "|--------|------|-------------|---------|\n"
    for output_item in data["output"]:
        output_name = next(iter(output_item))  # Get the output name
        output_type = output_item[output_name]["type"]
        output_description = output_item[output_name]["description"].replace("\n", " ")
        output_pattern = output_item[output_name].get("pattern", "").replace("\n", " ")
        output_table_row = f"| {output_name} | {output_type} | {output_description} | {output_pattern} |\n"
        outputs_table += output_table_row

    # Combine all sections into final Markdown content
    markdown_content = f"# Module: {data['name']}\n\n{data['description']}\n\n**Keywords:**\n\n{keywords_table}\n"
    markdown_content += f"**Tools:**\n\n{tools_table}\n"
    markdown_content += f"**Inputs:**\n\n{inputs_table}\n"
    markdown_content += f"**Outputs:**\n\n{outputs_table}\n"
    markdown_content += f"**Authors:**\n\n{', '.join(data['authors'])}\n\n"
    markdown_content += f"**Maintainers:**\n\n{', '.join(data['maintainers'])}\n\n"
    return markdown_content


if __name__ == "__main__":
    app()
