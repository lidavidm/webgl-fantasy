$(document).ready ->
  width = window.innerWidth
  height = window.innerHeight
  renderer = new THREE.WebGLRenderer
  renderer.setSize window.innerWidth, window.innerHeight
  renderer.setClearColorHex(0x000000, 1)
  $(document.body).append renderer.domElement

  scene = new THREE.Scene

  camera = new THREE.OrthographicCamera -width / 2, width / 2, -height / 2, height / 2, 0, 100
  scene.add camera

  grass = THREE.ImageUtils.loadTexture "grass.png"
  grass.wrapT = grass.wrapS = THREE.RepeatWrapping

  water = THREE.ImageUtils.loadTexture "water.png"
  water.wrapT = water.wrapS = THREE.RepeatWrapping

  tiles = 20
  size = 32
  plane = new THREE.PlaneGeometry tiles * size, tiles * size, tiles, tiles
  plane.materials[0] = new THREE.MeshBasicMaterial {
    map: grass,
    color: 0xffffff,
    wireframe: false
  }
  plane.materials[1] = new THREE.MeshBasicMaterial {
    color: 0xffffff,
    wireframe: true
  }
  console.log plane.materials, grass, THREE.RepeatWrapping

  for uvs in plane.faceVertexUvs
    for j in [0..uvs.length - 1]
      for uv in uvs[j]
        uv.u *= tiles
        uv.v *= tiles


  counter = 0
  for face in plane.faces
    face.materialIndex = 0
    counter = if counter is 0 then 1 else 0

  plane.faces[1].materialIndex = 0

  mesh = new THREE.Mesh plane, new THREE.MeshFaceMaterial
  mesh.rotation.x = -Math.PI / 2

  scene.add(mesh)

  stats = new Stats()
  stats.setMode 0
  stats.domElement.style.position = 'absolute'
  stats.domElement.style.left = '0px'
  stats.domElement.style.top = '0px'
  document.body.appendChild stats.domElement

  render = ->
    stats.begin()
    renderer.render scene, camera
    stats.end()
    window.requestAnimationFrame render

  render()