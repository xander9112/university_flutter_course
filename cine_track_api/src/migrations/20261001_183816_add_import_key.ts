import { MigrateUpArgs, MigrateDownArgs, sql } from '@payloadcms/db-postgres'

export async function up({ db, payload, req }: MigrateUpArgs): Promise<void> {
  await db.execute(sql`
   ALTER TABLE "movies" ADD COLUMN "import_key" varchar;
  CREATE UNIQUE INDEX "movies_import_key_idx" ON "movies" USING btree ("import_key");`)
}

export async function down({ db, payload, req }: MigrateDownArgs): Promise<void> {
  await db.execute(sql`
   DROP INDEX "movies_import_key_idx";
  ALTER TABLE "movies" DROP COLUMN "import_key";`)
}
