-- Usage:
--
-- dhall to-directory-tree --output ./test/libdeploy/check_fmode.bats <<< ./test/libdeploy/check_fmode.bats.dhall
--
let Prelude =
      https://github.com/dhall-lang/dhall-lang/raw/master/Prelude/package.dhall

let Bitmap = { u : Natural, g : Natural, o : Natural }

let setupTmpDir =
      ''
      ${"  "}# ---
        tmp_dir="$(mktemp -d)"; readonly tmp_dir
        cd "''${tmp_dir}" || return 1''

let renderBitmap =
      λ(b : Bitmap) → let r = Natural/show in "${r b.u}${r b.g}${r b.o}"

let reject =
      λ(bitmap : Bitmap) →
        let rMap =
            -- rMap: rendered (bit)map
              renderBitmap bitmap

        let rFile =
            -- rMap: rendered file
              "_file_${rMap}"

        in  ''
            @test 'check_fmode rejects ${rMap}' {
              touch "${rFile}" && chmod ${rMap} "${rFile}"
              check_fmode "${rFile}"

              [ $? != 0 ]
            }
            ''

let accept =
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
              check_fmode "${rFile}"

              [ $? = 0 ]
            }
            ''

let renderTest
    : Bitmap → Text
    = λ(bitmap : Bitmap) →
        if    Prelude.Natural.greaterThan bitmap.g 0
        then  reject bitmap
        else  if Prelude.Natural.greaterThan bitmap.o 0
        then  reject bitmap
        else  accept bitmap

let renderTests
    : List Bitmap → Text
    = Prelude.Text.concatMapSep "\n\n" Bitmap renderTest

let renderFile
    : List Bitmap → Text
    = λ(bitmaps : List Bitmap) →
        ''
        #!/usr/bin/env bats

        setup_file() {
          # shellcheck disable=SC1091
          . templates/libdeploy.sh
          cd "$BATS_TMPDIR"
        }

        setup() {
          set +e
        }

        ${renderTests bitmaps}''

let bitmaps
    : List Bitmap
    =
      -- Yikes what a mess; there's probably a much more sensible way to
      -- do this but I'm tired right now…
      --
      let bits =
            Prelude.List.generate 8 Natural (Prelude.Function.identity Natural)

      let gos =
            Prelude.List.generate
              8
              (List { g : Natural, o : Natural })
              ( λ(g : Natural) →
                  Prelude.List.map
                    Natural
                    { g : Natural, o : Natural }
                    (λ(o : Natural) → { g, o })
                    bits
              )

      let ugos =
            Prelude.List.generate
              8
              (List (List Bitmap))
              ( λ(u : Natural) →
                  Prelude.List.map
                    (List { g : Natural, o : Natural })
                    (List Bitmap)
                    ( λ(gos : List { g : Natural, o : Natural }) →
                        Prelude.List.map
                          { g : Natural, o : Natural }
                          Bitmap
                          (λ(go : { g : Natural, o : Natural }) → { u } ⫽ go)
                          gos
                    )
                    gos
              )

      in  Prelude.List.concat Bitmap (Prelude.List.concat (List Bitmap) ugos)

in  { `check_fmode.bats` = renderFile bitmaps }
