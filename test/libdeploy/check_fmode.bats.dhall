-- Usage:
--
-- dhall to-directory-tree --output ./test/libdeploy/check_fmode.bats <<< ./test/libdeploy/check_fmode.bats.dhall
--
let Bitmap = { u : Natural, g : Natural, o : Natural }

let setupTmpDir =
      ''
      ${"  "}# ---
        tmp_dir="$(mktemp -d)"; readonly tmp_dir
        cd "$\{tmp_dir}" || return 1''

let renderBitmap =
      λ(b : Bitmap) → let r = Natural/show in "${r b.u}${r b.g}${r b.o}"

let renderTestAccept =
      λ(bitmap : Bitmap) →
        let rMap =
            -- rMap: rendered (bit)map
              renderBitmap bitmap

        let rFile =
            -- rMap: rendered file
              "file_${rMap}"

        in  ''
            @test 'check_fmode accepts ${rMap}' {
            ${setupTmpDir}

              touch "${rFile}" && chmod ${rMap} "${rFile}"
              set +e # Hmmm, double check if we need to reset this… 🤔
              check_fmode "${rFile}"

              [ $? = 0 ]
            }
            ''

let bits = [ 0, 1, 2, 3, 4, 5, 6, 7 ]

in  renderTestAccept { u = 7, g = 7, o = 7 }
