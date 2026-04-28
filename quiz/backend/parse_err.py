import json
with open('pyright_errors.json', encoding='utf-16') as f:
    d = json.load(f)
with open('parsed_errors.txt', 'w', encoding='utf-8') as out:
    for e in d.get('generalDiagnostics', []):
        out.write(f"{e['file']} {e['range']['start']['line']}: {e['message']}\n")
