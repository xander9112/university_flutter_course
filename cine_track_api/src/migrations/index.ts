import * as migration_20261001_153756_initial from './20261001_153756_initial';

export const migrations = [
  {
    up: migration_20261001_153756_initial.up,
    down: migration_20261001_153756_initial.down,
    name: '20261001_153756_initial'
  },
];
