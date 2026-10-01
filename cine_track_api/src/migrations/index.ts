import * as migration_20261001_153756_initial from './20261001_153756_initial';
import * as migration_20261001_183816_add_import_key from './20261001_183816_add_import_key';

export const migrations = [
  {
    up: migration_20261001_153756_initial.up,
    down: migration_20261001_153756_initial.down,
    name: '20261001_153756_initial',
  },
  {
    up: migration_20261001_183816_add_import_key.up,
    down: migration_20261001_183816_add_import_key.down,
    name: '20261001_183816_add_import_key'
  },
];
