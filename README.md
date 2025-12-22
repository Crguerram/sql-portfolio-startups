# sql-portfolio-startups
📌 Descripción General:
Análisis de Impacto Social de las StartUps en el Perú. 
Realizado usando Postgre usando data sintética con Python + Faker.
Este proyecto implementa una base de datos relacional en PostgreSQL para analizar el ciclo de vida de startups, desde su fundación hasta etapas avanzadas de crecimiento (Seed, Early, Growth, Expansion y Exit).
El objetivo del proyecto es demostrar habilidades en SQL orientadas a análisis de datos ,no solo centrándonos en las consultas, sino tocando temas como: modelos entidad-relación con sus reglas semánticas y optimización
de performance mediante índices y EXPLAIN ANALYZE, entre otros.


🎯 Problema de negocio:
En el Perú muchas startups de impacto social carecen de visibilidad y seguimiento sistemático. A pesar de que existen incubadoras, programas de gobierno e inversionistas interesados; no hay una plataforma unificada que registre su información de manera estructurada ni su evolución en el tiempo.
Asimismo las startups atraviesan múltiples etapas de crecimiento, cada una con riesgos y necesidades distintas. Sin una estructura de datos adecuada, es difícil responder al algunas preguntas como:
¿Dónde y cuando se concentra la inversión?
¿Qué factores se asocian a etapas avanzadas de crecimiento?
Dado el espíritu emprendedor peruano, considero que este tema es relevante para nuestra economía nacional. Ahora si bien es cierto que la data con la que trabajamos es sintética, la lógica de las consultas no debería cambiar
al trabajar con la data real, permitiendo a tomadores de decisiones de las mismas a ejecutar sus planes de acción.

🗂️Modelo de datos:
El modelo entidad-relación contempla principalmente: startups y su relación con incubadoras,personas (fundadores,participantes e inversionistas), etapas de crecimiento,contratos con distintos tipos de inversionistas,entre otros. Se adjunta PDF con todos los scripts usados desde la creación de la base de datos con sus respectivas tablas y relaciones; así como también funciones,triggers,índices,entre otros.

🧪 Generación de datos:
La base utiliza datos sintéticos, generados de forma híbrida: combinación Python (librería Faker) y SQL. Si bien es cierto el propósito del proyecto no es centrarse en la manera de cómo la data fue creada, se adjuntarán 
los archivos necesarios para la respectiva creación de la misma.

🔍 Consultas analíticas destacadas: 
Se usaron 8 consultas de complejidad media con el propósito de abarcar la mayoría de temas pertinentes ligados a un Analista de Datos Jr.
Algunas de las consultas claves son:
-Incubadoras con mayor porcentaje de startups que alcanzan la etapa Expansion.
-Startups con mayor monto total de inversión y las etapas involucradas.
-Análisis temporal de inversión mensual y acumulada.
-Medición del tiempo de transición entre etapas.
Estas consultas nos permitiron tocar temas como joins,cte's , funciones ventana,agregaciones y manejo de fecha ,entre otros.

⚡ Optimización y performance:
Se diseñaron índices específicos en columnas clave utilizadas en:
-joins
-filtros temporales
-relaciones entre etapas.
El impacto se evaluó mediante EXPLAIN ANALYZE, comparación de índices vs sin índices y escenarios de 1k,10k y 100k.

🛠️ Tecnologías utilizadas:
PostgreSQL
SQL (CTEs, triggers, funciones, window functions)
Python
Faker
pgAdmin
GitHub

📄 Documentación completa:
El desarrollo completo del proyecto, incluyendo:
modelo conceptual,reglas semánticas,consultas detalladas y análisis de resultados se encuentra documentado en el informe académico:
📘 Proyecto SQL – Startups



