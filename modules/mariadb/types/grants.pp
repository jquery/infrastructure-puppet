# @summary an incomplete list of mariadb grants
#   when adding new entries please ensure it's the canonical form used in information_schema
type Mariadb::Grants = Variant[
  Array[
      Enum[
      'SELECT',
      'INSERT',
      'UPDATE',
      'DELETE',
      'SHOW VIEW',
      'RELOAD',
      'EVENT',
      'TRIGGER',
      'LOCK TABLES',
    ]
  ],
  Struct[{ all => Boolean }],
]
