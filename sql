SET @sql = NULL;
SELECT
  GROUP_CONCAT(DISTINCT
    CONCAT(
      'MAX(IF(t.NewTermType = ''',
      NewTermType,
      ''', t.NewTermName, NULL)) AS ',
      '''', NewTermType, ''''
    )
  ) INTO @sql
FROM 
(
	select 
		tr.object_id,
		tt.taxonomy NewTermType,
		GROUP_CONCAT(t.name SEPARATOR ',') NewTermName
	from
		wp_term_relationships AS tr INNER JOIN
		wp_term_taxonomy AS tt ON tt.term_taxonomy_id = tr.term_taxonomy_id INNER JOIN
		wp_terms AS t ON t.term_id = tt.term_id
	WHERE
		tt.taxonomy LIKE 'pa_%'
	group by      	
		tr.object_id,
		tt.taxonomy		
	
) t;

SET @sql = 
concat('SELECT DISTINCT
    post_title,
    id,
    __average_rating_value,
    __total_rating_count,
    review_summary,
    review_description,
    pros_cons_pros,
    pros_cons_cons,
    amazon_price,
    amazon_price_w,
    amazon_uk_price,
    amazon_uk_price_w,
    ebay_price,
    ebay_price_w,
    rei_m_rei_price,
    rei_w_rei_price_w,
    sportsshoes_price,
    sportsshoes_price_w,
    zappos_m_zappos_price,
    Zappos_w_zappos_price_w,
    cc.*
FROM (
	 SELECT 
            post_title,
            id,
            __average_rating_value,
            __total_rating_count,
            review_summary,
            description as review_description,
            pros_cons_pros,
            pros_cons_cons,
            amazon_price,
            amazon_price_w,
            amazon_uk_price,
            amazon_uk_price_w,
            ebay_price,
            ebay_price_w,
            rei_m_rei_price,
            rei_w_rei_price_w,
            sportsshoes_price,
            sportsshoes_price_w,
            zappos_m_zappos_price,
            Zappos_w_zappos_price_w
        FROM (
        SELECT 
            extended.post_title,
            MAX(id) as id,
            MAX(__average_rating_value) as __average_rating_value,
            MAX(__total_rating_count) as __total_rating_count,
            MAX(review_summary) as review_summary,
            MAX(description) as description,
            MAX(pros_cons_pros) as pros_cons_pros,
            MAX(pros_cons_cons) as pros_cons_cons,
            MAX(amazon_price) as amazon_price,
            MAX(amazon_price_w) as amazon_price_w,
            MAX(amazon_uk_price) as amazon_uk_price,
            MAX(amazon_uk_price_w) as amazon_uk_price_w,
            MAX(ebay_price) as ebay_price,
            MAX(ebay_price_w) as ebay_price_w,
            MAX(rei_m_rei_price) as rei_m_rei_price,
            MAX(rei_w_rei_price_w) as rei_w_rei_price_w,
            MAX(sportsshoes_price) as sportsshoes_price,
            MAX(sportsshoes_price_w) as sportsshoes_price_w,
            MAX(zappos_m_zappos_price) as zappos_m_zappos_price,
            MAX(Zappos_w_zappos_price_w) as Zappos_w_zappos_price_w
        FROM (
            SELECT  
                    p.post_title,
                    p.id,
                    case when m.meta_key = ''__average_rating_value'' then m.meta_value end as __average_rating_value,
                    case when m.meta_key = ''__total_rating_count'' then m.meta_value end as __total_rating_count,
                    case when m.meta_key = ''review_summary'' then m.meta_value end as review_summary,
                    case when m.meta_key = ''description'' then m.meta_value end as description,
                    case when m.meta_key = ''pros_cons_pros'' then m.meta_value end as pros_cons_pros,
                    case when m.meta_key = ''pros_cons_cons'' then m.meta_value end as pros_cons_cons,
                    case when m.meta_key = ''amazon_price'' then m.meta_value end as amazon_price,
                    case when m.meta_key = ''amazon_price_w'' then m.meta_value end as amazon_price_w,
                    case when m.meta_key = ''amazon_uk_price'' then m.meta_value end as amazon_uk_price,
                    case when m.meta_key = ''amazon_uk_price_w'' then m.meta_value end as amazon_uk_price_w,
                    case when m.meta_key = ''ebay_price'' then m.meta_value end as ebay_price,
                    case when m.meta_key = ''ebay_price_w'' then m.meta_value end as ebay_price_w,
                    case when m.meta_key = ''rei_m_rei_price'' then m.meta_value end as rei_m_rei_price,
                    case when m.meta_key = ''rei_w_rei_price_w'' then m.meta_value end as rei_w_rei_price_w,
                    case when m.meta_key = ''sportsshoes_price'' then m.meta_value end as sportsshoes_price,
                    case when m.meta_key = ''sportsshoes_price_w'' then m.meta_value end as sportsshoes_price_w,
                    case when m.meta_key = ''zappos_m_zappos_price'' then m.meta_value end as zappos_m_zappos_price,
                    case when m.meta_key = ''Zappos_w_zappos_price_w'' then m.meta_value end as Zappos_w_zappos_price_w
			FROM
				wp_posts AS p
			INNER JOIN
				wp_postmeta AS m on p.id = m.post_id
			WHERE
			m.meta_key in(
				''__average_rating_value'',''__total_rating_count'',''review_summary'',''description'',''pros_cons_pros'',''pros_cons_cons'',
				''amazon_price'', ''amazon_price_w'', ''amazon_uk_price'', ''amazon_uk_price_w'',
				''ebay_price'', ''ebay_price_w'', 
				''rei_m_rei_price'', ''rei_w_rei_price_w'',
				''sportsshoes_price'', ''sportsshoes_price_w'',
				''zappos_m_zappos_price'', ''Zappos_w_zappos_price_w''
			)
				AND
					m.meta_value is not null
				AND 
					m.meta_value <> ''''

        ) as extended
        group by extended.post_title
        ) as pivot
        where 
        __average_rating_value is not null
    ) as p	
INNER JOIN
(
   SELECT t.object_id, ', @sql ,' 
   FROM 
   (
		select 
			tr.object_id,
			tt.taxonomy NewTermType,
			GROUP_CONCAT(t.name SEPARATOR '','') NewTermName
		from
			wp_term_relationships AS tr INNER JOIN
			wp_term_taxonomy AS tt ON tt.term_taxonomy_id = tr.term_taxonomy_id INNER JOIN
			wp_terms AS t ON t.term_id = tt.term_id
		WHERE
			tt.taxonomy LIKE ''pa_%''
		group by      	
			tr.object_id,
			tt.taxonomy
		
	) t
	group by t.object_id

) cc on p.id = cc.object_id	 
INNER JOIN 
    wp_postmeta AS m on p.id = m.post_id   
 where
    	__average_rating_value <> ''NaN''
	ORDER BY p.__average_rating_value desc

    ;');
				   

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
