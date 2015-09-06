SELECT
  specialist_id,
  firstname,
  lastname,
  specialization_ids
FROM (
  SELECT
    id AS specialist_id,
    firstname,
    lastname
  FROM specialists
  WHERE
    specialists.firstname = 'Brian'
  GROUP BY specialist_id
) e1 LEFT JOIN LATERAL (
  SELECT
    array(
      SELECT specializations.id
      FROM specializations
      INNER JOIN specialist_specializations
      ON specialist_specializations.specialization_id = specializations.id
      WHERE specialist_specializations.specialist_id = e1.specialist_id
    ) AS specialization_ids
) e2 ON true;

( with just cities through locations)
SELECT
  specialist_id,
  firstname,
  lastname,
  city_ids
FROM (
  SELECT
    id AS specialist_id,
    firstname,
    lastname
  FROM specialists
  GROUP BY specialist_id
) e1 LEFT JOIN LATERAL (
  SELECT
    array(
      SELECT cities.id
      FROM cities
      INNER JOIN addresses
      ON cities.id = addresses.city_id
      INNER JOIN locations
      ON locations.address_id = addresses.id
      INNER JOIN offices
      ON locations.locatable_id = offices.id
      INNER JOIN specialist_offices
      ON specialist_offices.id = offices.id
      INNER JOIN specialists
      ON specialist_offices.specialist_id = specialists.id
      WHERE locations.locatable_type = 'Office'
      AND specialists.id = e1.specialist_id
    ) AS city_ids
) e2 ON true;



SELECT
  specialist_id,
  firstname,
  lastname,
  city_ids
FROM (
  SELECT
    id AS specialist_id,
    firstname,
    lastname,
    categorization_mask
  FROM specialists
  GROUP BY specialist_id
) e1 LEFT JOIN LATERAL (
  SELECT
    array(
      SELECT
      CASE e1.categorization_mask
      WHEN '1'
        THEN cities.id
        FROM cities
        INNER JOIN addresses
        ON cities.id = addresses.city_id
        INNER JOIN locations
        ON locations.address_id = addresses.id
        INNER JOIN offices
        ON locations.locatable_id = offices.id
        INNER JOIN specialist_offices
        ON specialist_offices.id = offices.id
        INNER JOIN specialists
        ON specialist_offices.specialist_id = specialists.id
        WHERE locations.locatable_type = 'Office'
        AND specialists.id = e1.specialist_id
      ELSE
        NULL
      END
    ) AS city_ids
) e2 ON true;
