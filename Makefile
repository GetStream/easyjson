PKG=github.com/GetStream/easyjson
GOPATH:=$(PWD)/_root:$(GOPATH)
export GOPATH
export GO111MODULE=off

all: test

_root/src/$(PKG):
	mkdir -p $@
	for i in $$PWD/* ; do ln -s $$i $@/`basename $$i` ; done

root: _root/src/$(PKG)

clean:
	rm -rf _root
	rm -rf tests/*_easyjson.go

build:
	go build -i -o _root/bin/easyjson $(PKG)/easyjson

generate: root build
	_root/bin/easyjson -stubs \
		_root/src/$(PKG)/tests/snake.go \
		_root/src/$(PKG)/tests/data.go \
		_root/src/$(PKG)/tests/omitempty.go \
		_root/src/$(PKG)/tests/nothing.go \
		_root/src/$(PKG)/tests/named_type.go \
		_root/src/$(PKG)/tests/custom_map_key_type.go \
		_root/src/$(PKG)/tests/embedded_type.go \
		_root/src/$(PKG)/tests/reference_to_pointer.go \

	_root/bin/easyjson -all _root/src/$(PKG)/tests/data.go
	_root/bin/easyjson -all _root/src/$(PKG)/tests/nothing.go
	_root/bin/easyjson -all _root/src/$(PKG)/tests/errors.go
	_root/bin/easyjson -all _root/src/$(PKG)/tests/extra_fields_type.go
	_root/bin/easyjson -snake_case _root/src/$(PKG)/tests/snake.go
	_root/bin/easyjson -omit_empty _root/src/$(PKG)/tests/omitempty.go
	_root/bin/easyjson -build_tags=use_easyjson _root/src/$(PKG)/benchmark/data.go
	_root/bin/easyjson _root/src/$(PKG)/tests/nested_easy.go
	_root/bin/easyjson _root/src/$(PKG)/tests/named_type.go
	_root/bin/easyjson _root/src/$(PKG)/tests/custom_map_key_type.go
	_root/bin/easyjson _root/src/$(PKG)/tests/embedded_type.go
	_root/bin/easyjson _root/src/$(PKG)/tests/reference_to_pointer.go
	_root/bin/easyjson _root/src/$(PKG)/tests/key_marshaler_map.go
	_root/bin/easyjson -disallow_unknown_fields _root/src/$(PKG)/tests/disallow_unknown.go

test: generate root
	go test \
		$(PKG)/tests \
		$(PKG)/jlexer \
		$(PKG)/gen \
		$(PKG)/buffer
	go test -benchmem -tags use_easyjson -bench . $(PKG)/benchmark
	golint -set_exit_status _root/src/$(PKG)/tests/*_easyjson.go

bench-other: generate root
	@go test -benchmem -bench . $(PKG)/benchmark
	@go test -benchmem -tags use_ffjson -bench . $(PKG)/benchmark
	@go test -benchmem -tags use_jsoniter -bench . $(PKG)/benchmark
	@go test -benchmem -tags use_codec -bench . $(PKG)/benchmark

bench-python:
	benchmark/ujson.sh


.PHONY: root clean generate test build
