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
