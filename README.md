# hb-flatten-json

**hb-flatten-json** é uma biblioteca escrita em Harbour para manipulação de JSON, permitindo a conversão entre estruturas aninhadas e formatos achatados, facilitando o processamento e a análise de dados.

## Recursos
- **Flatten**: Converte um JSON aninhado em um formato achatado.
- **UnFlatten**: Restaura o JSON achatado para sua estrutura original.
- Suporte para arrays de objetos.
- Implementação otimizada para Harbour.

## Instalação

Para utilizar a biblioteca, basta incluir os arquivos-fonte no seu projeto Harbour:

```shell
hbmk2 seu_projeto.hbp -i src/core/hb_flatten_json.prg
```

## Uso

### Exemplo de Flatten
```harbour
#include "hbjson.ch"

REQUEST HB_JSON

LOCAL cJson, hData, cFlattenedJson

cJson := '{ "pessoa": { "nome": "Naldo", "idade": 30 } }'
hData := hb_jsonDecode( cJson )
cFlattenedJson := Flatten( hData )

? hb_jsonEncode( cFlattenedJson )
```

### Exemplo de UnFlatten
```harbour
LOCAL hFlattened, hOriginal

hFlattened := { "pessoa.nome": "Naldo", "pessoa.idade": 30 }
hOriginal := UnFlatten( hFlattened )

? hb_jsonEncode( hOriginal )
```

## Testes
Os testes estão localizados em `src/tst/flattenjson.prg`. Para executá-los:

```shell
hbmk2 flattenjson.hbp && ./flattenjson
```

## Contribuição

Contribuições são bem-vindas! Para contribuir:
1. Faça um fork do repositório.
2. Crie um branch para sua feature (`git checkout -b minha-feature`).
3. Faça commit das suas alterações (`git commit -m 'Minha nova feature'`).
4. Envie para o repositório (`git push origin minha-feature`).
5. Abra um Pull Request.

## Licença
Este projeto está licenciado sob a [Apache-2.0](LICENSE).

---

**Repositório:** [hb-flatten-json](https://github.com/naldodj/naldodj-hb-flatten-json)
