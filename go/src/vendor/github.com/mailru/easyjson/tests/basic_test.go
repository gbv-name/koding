package tests

import (
	"reflect"
	"testing"

	"encoding/json"

	"github.com/mailru/easyjson"
	"github.com/mailru/easyjson/jwriter"
)

type testType interface {
	json.Marshaler
	json.Unmarshaler
}

var testCases = []struct {
	Decoded testType
	Encoded string
}{
	{&primitiveTypesValue, primitiveTypesString},
	{&namedPrimitiveTypesValue, namedPrimitiveTypesString},
	{&structsValue, structsString},
	{&omitEmptyValue, omitEmptyString},
	{&snakeStructValue, snakeStructString},
	{&omitEmptyDefaultValue, omitEmptyDefaultString},
	{&optsValue, optsString},
	{&rawValue, rawString},
	{&stdMarshalerValue, stdMarshalerString},
	{&unexportedStructValue, unexportedStructString},
	{&excludedFieldValue, excludedFieldString},
	{&sliceValue, sliceString},
	{&arrayValue, arrayString},
	{&mapsValue, mapsString},
	{&deepNestValue, deepNestString},
	{&IntsValue, IntsString},
	{&mapStringStringValue, mapStringStringString},
}

func TestMarshal(t *testing.T) {
	for i, test := range testCases {
		data, err := test.Decoded.MarshalJSON()
		if err != nil {
			t.Errorf("[%d, %T] MarshalJSON() error: %v", i, test.Decoded, err)
		}

		got := string(data)
		if got != test.Encoded {
			t.Errorf("[%d, %T] MarshalJSON(): got \n%v\n\t\t want \n%v", i, test.Decoded, got, test.Encoded)
		}
	}
}

func TestUnmarshal(t *testing.T) {
	for i, test := range testCases {
		v1 := reflect.New(reflect.TypeOf(test.Decoded).Elem()).Interface()
		v := v1.(testType)

		err := v.UnmarshalJSON([]byte(test.Encoded))
		if err != nil {
			t.Errorf("[%d, %T] UnmarshalJSON() error: %v", i, test.Decoded, err)
		}

		if !reflect.DeepEqual(v, test.Decoded) {
			t.Errorf("[%d, %T] UnmarshalJSON(): got \n%+v\n\t\t want \n%+v", i, test.Decoded, v, test.Decoded)
		}
	}
}

func TestRawMessageSTD(t *testing.T) {
	type T struct {
		F    easyjson.RawMessage
		Fnil easyjson.RawMessage
	}

	val := T{F: easyjson.RawMessage([]byte(`"test"`))}
	str := `{"F":"test","Fnil":null}`

	data, err := json.Marshal(val)
	if err != nil {
		t.Errorf("json.Marshal() error: %v", err)
	}
	got := string(data)
	if got != str {
		t.Errorf("json.Marshal() = %v; want %v", got, str)
	}

	wantV := T{F: easyjson.RawMessage([]byte(`"test"`)), Fnil: easyjson.RawMessage([]byte("null"))}
	var gotV T

	err = json.Unmarshal([]byte(str), &gotV)
	if err != nil {
		t.Errorf("json.Unmarshal() error: %v", err)
	}
	if !reflect.DeepEqual(gotV, wantV) {
		t.Errorf("json.Unmarshal() = %v; want %v", gotV, wantV)
	}
}

func TestParseNull(t *testing.T) {
	var got, want SubStruct
	if err := easyjson.Unmarshal([]byte("null"), &got); err != nil {
		t.Errorf("Unmarshal() error: %v", err)
	}

	if !reflect.DeepEqual(got, want) {
		t.Errorf("Unmarshal() = %+v; want %+v", got, want)
	}
}

var testSpecialCases = []struct {
	EncodedString string
	Value         string
}{
	{`"Username \u003cuser@example.com\u003e"`, `Username <user@example.com>`},
	{`"Username\ufffd"`, "Username\xc5"},
	{`"????????z????????"`, "????????z????????"},
	{`"????????\ufffd????????"`, "????????\xc5????????"},
	{`"??????"`, "??????"},
	{`"???\ufffd???"`, "???\xc5???"},
	{`"????????\u2028"`, "????????\xE2\x80\xA8"},
	{`"\\\r\n\t\""`, "\\\r\n\t\""},
	{`"??"`, "??"},
}

func TestSpecialCases(t *testing.T) {
	for i, test := range testSpecialCases {
		w := jwriter.Writer{}
		w.String(test.Value)
		got := string(w.Buffer.BuildBytes())
		if got != test.EncodedString {
			t.Errorf("[%d] Encoded() = %+v; want %+v", i, got, test.EncodedString)
		}
	}
}

func TestOverflowArray(t *testing.T) {
	var a Arrays
	err := easyjson.Unmarshal([]byte(arrayOverflowString), &a)
	if err != nil {
		t.Error(err)
	}
	if a != arrayValue {
		t.Errorf("Unmarshal(%v) = %+v; want %+v", arrayOverflowString, a, arrayValue)
	}
}

func TestUnderflowArray(t *testing.T) {
	var a Arrays
	err := easyjson.Unmarshal([]byte(arrayUnderflowString), &a)
	if err != nil {
		t.Error(err)
	}
	if a != arrayUnderflowValue {
		t.Errorf("Unmarshal(%v) = %+v; want %+v", arrayUnderflowString, a, arrayUnderflowValue)
	}
}

func TestEncodingFlags(t *testing.T) {
	for i, test := range []struct {
		Flags jwriter.Flags
		In    easyjson.Marshaler
		Want  string
	}{
		{0, EncodingFlagsTestMap{}, `{"F":null}`},
		{0, EncodingFlagsTestSlice{}, `{"F":null}`},
		{jwriter.NilMapAsEmpty, EncodingFlagsTestMap{}, `{"F":{}}`},
		{jwriter.NilSliceAsEmpty, EncodingFlagsTestSlice{}, `{"F":[]}`},
	} {
		w := &jwriter.Writer{Flags: test.Flags}
		test.In.MarshalEasyJSON(w)

		data, err := w.BuildBytes()
		if err != nil {
			t.Errorf("[%v] easyjson.Marshal(%+v) error: %v", i, test.In, err)
		}

		v := string(data)
		if v != test.Want {
			t.Errorf("[%v] easyjson.Marshal(%+v) = %v; want %v", i, test.In, v, test.Want)
		}
	}

}
