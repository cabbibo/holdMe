
uniform float time;
uniform sampler2D t_audio;
uniform vec4 links[7];
uniform vec4 activeLink;
uniform vec4 hoveredLink;

uniform sampler2D t_matcap;
uniform sampler2D t_normal;
uniform sampler2D t_text;
uniform float textRatio;

uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

varying vec3 vPos;
varying vec3 vCam;
varying vec3 vNorm;

varying vec3 vMNorm;
varying vec3 vMPos;

varying vec2 vUv;


$uvNormalMap
$semLookup
$hsv


// Branch Code stolen from : https://www.shadertoy.com/view/ltlSRl
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float MAX_TRACE_DISTANCE = 5.0;             // max trace distance
const float INTERSECTION_PRECISION = 0.01;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 25;
const float PI = 3.14159;



$smoothU
$opU
$sdCapsule
$sdBox



//--------------------------------
// Modelling 
//--------------------------------
vec2 map( vec3 pos ){  

    vec3 og = pos;

    vec2 res = vec2( 1000000. , 0. );



    for( int i = 0; i < 7; i++ ){
      res = smoothU( res , vec2( length( pos  - links[i].xyz ) - .2 , float( i ) + 10. ) , .1 );
    }


    vec2 caps;

    if( hoveredLink.w > .1 ){
      caps = vec2( sdCapsule( pos , hoveredLink.xyz ,  hoveredLink.xyz * .8 , .1 ) , 30. );
      res = smoothU( res , caps , .2 ) ;
    }



    // interface tracing
    if( activeLink.w > .1 ){
      caps = vec2( sdCapsule( pos , activeLink.xyz ,  vec3( 0. ) , .1 ) , 20. );
      res = smoothU( res , caps , .2 ) ;
    }


    pos.x += .1 * sin( pos.x * 20. );
    pos.y += .1 * sin( pos.y * 10. );
    pos.z += .1 * sin( pos.z * 10. );

 
    vec2 centerBlob = vec2( length( pos  ) - .4 , 1. );

    res = smoothU( res , centerBlob , .2 );



    //text

    float text = sdBox( og - vec3( 0. , -1. , 0. ) , vec3( textRatio * .2 , .2 , .01 ));
    res = opU( res , vec2( text , 100.));

    return res;
    
}


$calcIntersection
$calcNormal
$calcAO




void main(){

  vec3 fNorm = uvNormalMap( t_normal , vPos , vUv , vNorm , .6 , -.1 );

  vec3 ro = vPos;
  vec3 rd = normalize( vPos - vCam );

  vec3 p = vec3( 0. );
  vec3 col =  vec3( 0. );

  float m = max(0.,dot( -rd , fNorm ));

  //col += fNorm * .5 + .5;

  vec3 refr = refract( rd , fNorm , 1. / 1.) ;

  vec2 res = calcIntersection( ro , refr );

  if( res.y > -.5 ){

    p = ro + refr * res.x;
    vec3 n = calcNormal( p );

    //col += n * .5 + .5;



    col +=  texture2D( t_matcap , semLookup( refr , n , modelViewMatrix , normalMatrix ) ).xyz;

    col *= hsv( res.y * .1 , 1. , 1. );

    if( res.y >= 90. ){

      vec2 lookup = p.xy;
      //lookup.x += .5;
      lookup.x /= textRatio;
      lookup.x /= .4;
      lookup.x += .5;
      lookup.y += 1.2;
      lookup.y *= 2.3;
      //lookup.y *= 1.4;

      col *= texture2D( t_text , lookup ).xyz;
      //col += vec3( 1.1 );
    }

    //col -= texture2D( t_audio , vec2(  abs( n.x ) , 0. ) ).xyz;

  }



  if( abs( vUv.x - .5)> .48 || abs( vUv.y - .5)> .48 ){
    col += vec3( .5 );

  }

  gl_FragColor = vec4( col , 1. );

}










