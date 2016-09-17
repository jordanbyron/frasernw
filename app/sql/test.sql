SELECT
  id,
  array(
    SELECT specializations.id
    FROM specializations
    INNER JOIN specialist_specializations
    ON specialist_specializations.specialization_id = specializations.id
    WHERE specialist_specializations.specialist_id = specialists.id
  ) AS specialization_ids
FROM specialists;
