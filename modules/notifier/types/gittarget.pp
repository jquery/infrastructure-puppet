# @summary git target to listen
type Notifier::GitTarget = Variant[
  Struct[{ branch => String[1], }],
  Struct[{ tag => String[1], }],
]
