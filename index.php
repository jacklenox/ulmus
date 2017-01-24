<?php
/**
 * The header for our theme.
 *
 * This is the template that displays all of the <head> section and everything up until <div id="content">
 *
 * @link https://developer.wordpress.org/themes/basics/template-files/#template-partials
 *
 * @package Ulmus
 */

?><!DOCTYPE html>
<html <?php language_attributes(); ?>>
<head>
<meta charset="<?php bloginfo( 'charset' ); ?>">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="profile" href="http://gmpg.org/xfn/11">

<?php wp_head(); ?>
</head>

<body id="body" <?php body_class(); ?>>


<?php wp_footer(); ?>

<script>
    var node = document.getElementById( 'body' );
    var app = Elm.Ulmus.embed( node );
    app.ports.wpOptions.send( 'http://wp-rest-api-demo.dev/wp-json/wp/v2/posts' );
</script>

</body>
</html>
