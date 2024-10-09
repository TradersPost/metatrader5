// This utility uses a modified copy of JAson (https://github.com/vivazzi/JAson)
#property copyright "Copyright © 2006-2017, Alexey Sergeev, Artem Maltsev and contributors: https://github.com/vivazzi/JAson/blob/main/CONTRIBUTORS.md"
#property version "1.13.0"
#property description "jsonON Serialization and Deserialization"
#property strict

//+------------------------------------------------------------------+
//|                                    TradersPostWebhookRequest.mqh |
//|                                                 TradersPost, Inc |
//|                                           https://traderspost.io |
//+------------------------------------------------------------------+
#property link "https://traderspost.io"

class TradersPostWebhookRequest
{
private:
    string m_url;

public:
    // Constructor
    TradersPostWebhookRequest(string url)
    {
        m_url = url;
    }

    // Method to send the request
    bool SendRequest(string jsonPayload)
    {
        Print("Sending Payload: ", jsonPayload);

        // Set the HTTP method and headers
        string method = "POST";
        string headers = "Content-Type: application/json\r\n";

        // Convert the JSON payload to a char array
        uchar data[];
        StringToCharArray(jsonPayload, data);

        // Variables to hold the response
        uchar result[];
        string result_headers;

        // Timeout in milliseconds
        int timeout = 5000;

        // Make the web request
        int res = WebRequest(method, m_url, headers, timeout, data, result, result_headers);

        string responseBody = CharArrayToString(result);
        Print("Response body: ", responseBody);

        if (res == 200)
        {
            // Request was successful
            return true;
        }
        else
        {
            // Handle errors
            PrintFormat("WebRequest failed, error code: %d", res);
            return false;
        }
    }
};

#ifdef DEBUG
    #define DEBUG_PRINT_KEY() Print(key+" "+string(__LINE__))
#else
    #define DEBUG_PRINT_KEY()
#endif


//------------------------------------------------------------------	enum enJAType
enum enJAType { jtUNDEF, jtNULL, jtBOOL, jtINT, jtDBL, jtSTR, jtARRAY, jtOBJ };

//------------------------------------------------------------------	class TPJSON
class TPJSON {

public:
    TPJSON children[];
	string key;
	string l_key;
	TPJSON* parent;
	enJAType type;

	bool bool_v;
	long int_v;
	double dbl_v; int dbl_precision;
	string str_v;
	
	static int code_page;

	// constructors & destructor
	TPJSON() {
	    Clear();
    }

	TPJSON(TPJSON* a_parent, enJAType a_type) {
	    Clear();
	    type = a_type;
	    parent = a_parent;
    }

	TPJSON(enJAType t, string str) {
	    Clear();
	    FromStr(t, str);
    }

	TPJSON(const int v) {
	    Clear();
	    type = jtINT;
	    int_v = v;
	    dbl_v = (double)int_v;
	    str_v = IntegerToString(int_v);
	    bool_v = int_v != 0;
    }

	TPJSON(const long v) {
	    Clear();
	    type = jtINT;
	    int_v = v;
	    dbl_v = (double)int_v;
	    str_v = IntegerToString(int_v);
	    bool_v = int_v != 0;
    }

	TPJSON(const double v, int precision=-100) {
	    Clear();
	    type = jtDBL;
	    dbl_v = v;
	    if (precision > -100) dbl_precision = precision;
	    int_v = (long)dbl_v;
	    str_v = DoubleToString(dbl_v, dbl_precision);
	    bool_v = int_v != 0;
    }

	TPJSON(const bool v) {
	    Clear();
	    type = jtBOOL;
	    bool_v = v;
	    int_v = bool_v;
	    dbl_v = bool_v;
	    str_v = IntegerToString(int_v);
    }

	TPJSON(const TPJSON& a) {
	    Clear();
	    Copy(a);
    }

	~TPJSON() { Clear(); }

	// --- METHODS ---
	int Size() { return ArraySize(children); }

	virtual bool IsNumeric() {
	    return type == jtDBL || type == jtINT;
    }

	virtual void Clear(enJAType jt=jtUNDEF, bool save_key=false) {
	    parent = NULL;
	    if (!save_key) key = "";
	    type = jt;
	    bool_v = false;
	    int_v = 0;
	    dbl_v = 0;
	    dbl_precision = 8;
	    str_v = "";
	    ArrayResize(children, 0, 100);
    }

    // - copy -
	virtual bool Copy(const TPJSON &a) {
	    if (key == "") key = a.key;
	    CopyData(a);
	    return true;
    }

	virtual void CopyData(const TPJSON& a) {
	    type = a.type;
	    bool_v = a.bool_v;
	    int_v = a.int_v;
	    dbl_v = a.dbl_v;
	    dbl_precision = a.dbl_precision;
	    str_v = a.str_v;
	    CopyArr(a);
    }

	virtual void CopyArr(const TPJSON& a) {
	    int n = ArrayResize(children, ArraySize(a.children));
	    for (int i=0; i<n; i++) {
	        children[i] = a.children[i];
	        children[i].parent = GetPointer(this);
        }
    }

    // - search -
	virtual TPJSON* FindKey(string a_key) {
	    for (int i=Size()-1; i>=0; --i)
	        if (children[i].key == a_key) return GetPointer(children[i]);

        return NULL;
    }

	virtual bool HasKey(string a_key, enJAType a_type=jtUNDEF) {
	    TPJSON* e = FindKey(a_key);

	    if (CheckPointer(e) != POINTER_INVALID && (a_type == jtUNDEF || a_type == e.type)) return true;

        return false;
    }

    // - get & assignments -
	virtual TPJSON* operator[](string a_key);
	virtual TPJSON* operator[](int i);

	void operator=(const TPJSON &a) {
	    Copy(a);
	}

	void operator=(const int v) {
	    type = jtINT;
	    int_v = v;
	    dbl_v = (double)int_v;
	    bool_v = int_v != 0;
    }

	void operator=(const long v) {
	    type = jtINT;
	    int_v = v;
	    dbl_v = (double)int_v;
	    bool_v = int_v != 0;
    }

	void operator=(const double v) {
	    type = jtDBL;
	    dbl_v = v;
	    int_v = (long)dbl_v;
	    bool_v = int_v != 0;
    }
	void operator=(const bool v) {
	    type = jtBOOL;
	    bool_v = v;
	    int_v = (long)bool_v;
	    dbl_v = (double)bool_v;
    }

	void operator=(string v) {
	    type = (v != NULL) ? jtSTR : jtNULL;
	    str_v = v;
	    int_v = StringToInteger(str_v);
	    dbl_v = StringToDouble(str_v);
	    bool_v = v != NULL;
    }

    // - comparasions -
	bool operator==(const int v) {return int_v == v; }
	bool operator==(const long v) { return int_v == v; }
	bool operator==(const double v) { return dbl_v == v; }
	bool operator==(const bool v) { return bool_v == v; }
	bool operator==(string v) { return str_v == v; }

	bool operator!=(const int v) { return int_v != v; }
	bool operator!=(const long v) { return int_v != v; }
	bool operator!=(const double v) { return dbl_v != v; }
	bool operator!=(const bool v) { return bool_v != v; }
	bool operator!=(string v) { return str_v != v; }

    // - to formats -
	long ToInt() const { return int_v; }
	double ToDbl() const { return dbl_v; }
	bool ToBool() const { return bool_v; }
	string ToStr() { return str_v; }

    // - from / get str -
	virtual void FromStr(enJAType t, string str) {
		type = t;
		switch (type) {
            case jtBOOL: bool_v = (StringToInteger(str) != 0); int_v = (long)bool_v; dbl_v = (double)bool_v; str_v = str; break;
            case jtINT: int_v = StringToInteger(str); dbl_v = (double)int_v; str_v = str; bool_v = int_v != 0; break;
            case jtDBL: dbl_v = StringToDouble(str); int_v = (long)dbl_v; str_v = str; bool_v = int_v != 0; break;
            case jtSTR: str_v = Unescape(str); type = (str_v != NULL)?jtSTR:jtNULL; int_v = StringToInteger(str_v); dbl_v = StringToDouble(str_v); bool_v = str_v != NULL; break;
		}
	}

	virtual string GetStr(char& json[], int i, int len) {
	    if (len == 0) return "";
		return CharArrayToString(json, i, len, TPJSON::code_page);
    }

    // - Set methods -
	virtual void Set(const TPJSON& a) {
	    if (type == jtUNDEF) type = jtOBJ; CopyData(a);
    }

	virtual void Set(const TPJSON& list[]) {
        if (type == jtUNDEF) type = jtARRAY;
        int n = ArrayResize(children, ArraySize(list), 100);
        for (int i=0; i<n; ++i) {
            children[i] = list[i];
            children[i].parent = GetPointer(this);
        }
    }

    // - Add methods -
	virtual TPJSON* Add(const TPJSON& item) {  // adding
	    if (type == jtUNDEF) type = jtARRAY;
	    /*ASSERT(type == jtOBJ || type == jtARRAY);*/
	    return AddBase(item);
    }

	virtual TPJSON* Add(const int v) {
	    TPJSON item(v);
	    return Add(item);
    }

	virtual TPJSON* Add(const long v) {
	    TPJSON item(v);
	    return Add(item);
    }

	virtual TPJSON* Add(const double v, int precision=-2) {
	    TPJSON item(v, precision);
	    return Add(item);
    }

	virtual TPJSON* Add(const bool v) {
	    TPJSON item(v);
	    return Add(item);
    }

	virtual TPJSON* Add(string v) {
	    TPJSON item(jtSTR, v);
	    return Add(item);
    }

    // - helper adding methods -
	virtual TPJSON* AddBase(const TPJSON &item) {
	    int c = Size();
	    ArrayResize(children, c+1, 100);
	    children[c] = item;
	    children[c].parent = GetPointer(this);
	    return GetPointer(children[c]);
    }

	virtual TPJSON* New() {
	    if (type == jtUNDEF) type = jtARRAY;
	    /*ASSERT(type == jtOBJ || type == jtARRAY);*/
	    return NewBase();
    }

	virtual TPJSON* NewBase() {
	    int c = Size(); ArrayResize(children, c+1, 100); return GetPointer(children[c]);
    }

    // - Escape & Unescape -
	virtual string Escape(string v);
	virtual string Unescape(string v);

    // - serializes & deserializes -
	virtual void Serialize(string &json, bool is_key=false, bool use_comma=false);

	virtual string Serialize() {
	    string json;
	    Serialize(json);
	    return json;
    }

	virtual bool Deserialize(char& json[], int len, int &i);
	virtual bool ExtrStr(char& json[], int len, int &i);

	virtual bool Deserialize(string json, int acp=CP_ACP) {
	    int i = 0;
	    Clear();
	    TPJSON::code_page = acp;
	    char arr[];
	    int len = StringToCharArray(json, arr, 0, WHOLE_ARRAY, TPJSON::code_page);
	    return Deserialize(arr, len, i);
    }

	virtual bool Deserialize(char& json[], int acp=CP_ACP) {
	    int i = 0;
	    Clear();
	    TPJSON::code_page = acp;
	    return Deserialize(json, ArraySize(json), i);
    }
};

int TPJSON::code_page = CP_ACP;

//------------------------------------------------------------------	operator[]
TPJSON* TPJSON::operator[](string a_key) {
    if (type == jtUNDEF) type = jtOBJ;
    TPJSON* v = FindKey(a_key);
    if (v) return v;

    TPJSON b(GetPointer(this), jtUNDEF);
    b.key = a_key;
    v = Add(b);
    return v;
}

//------------------------------------------------------------------	operator[]
TPJSON* TPJSON::operator[](int i) {
	if (type == jtUNDEF) type = jtARRAY;
	while (i >= Size()) {
	    TPJSON b(GetPointer(this), jtUNDEF);

	    if (CheckPointer(Add(b)) == POINTER_INVALID) return NULL;
    }
	return GetPointer(children[i]);
}

//------------------------------------------------------------------	Serialize
void TPJSON::Serialize(string& json, bool is_key/*=false*/, bool use_comma/*=false*/) {
	if (type == jtUNDEF) return;
	if (use_comma) json += ",";
	if (is_key) json += StringFormat("\"%s\":", key);

	int _n = Size();

	switch (type) {
        case jtNULL: json += "null"; break;
        case jtBOOL: json += (bool_v ? "true" : "false"); break;
        case jtINT: json += IntegerToString(int_v); break;
        case jtDBL: json += DoubleToString(dbl_v, dbl_precision); break;
        case jtSTR: { string ss = Escape(str_v); if (StringLen(ss) > 0) json += StringFormat("\"%s\"", ss); else json += "null"; } break;
        case jtARRAY: json += "["; for (int i=0; i<_n; i++) children[i].Serialize(json, false, i > 0); json += "]"; break;
        case jtOBJ: json += "{"; for (int i=0; i<_n; i++) children[i].Serialize(json, true, i > 0); json += "}"; break;
	}
}

//------------------------------------------------------------------	Deserialize
bool TPJSON::Deserialize(char& json[], int len, int &i) {
	string num = "0123456789+-.eE";
	int i0 = i;
	for (; i<len; i++) {
		char c = json[i];
		if (c == 0) break;

		switch (c) {
		    // miss spaces from name
            case '\t': case '\r': case '\n': case ' ':  {
                i0 = i+1; break;
            }

            // the beginning of the array. create objects and take them from json
            case '[': {
                i0 = i+1;
                if (type != jtUNDEF) { DEBUG_PRINT_KEY(); return false; }  // if value already has type, then this is an error

                type = jtARRAY;  // set the value type
                i++; TPJSON val(GetPointer(this), jtUNDEF);
                while (val.Deserialize(json, len, i))
                {
                    if (val.type != jtUNDEF) Add(val);
                    if (val.type == jtINT || val.type == jtDBL || val.type == jtARRAY) i++;
                    val.Clear(); val.parent = GetPointer(this);
                    if (json[i] == ']') break;
                    i++; if (i >= len) { DEBUG_PRINT_KEY(); return false; }
                }
                return json[i] == ']' || json[i] == 0;

                break;
            }

             // end of array, current value must be an array
            case ']': {
                if (!parent) return false;

                return parent.type == jtARRAY;
            }

            case ':': {
                if (l_key == "") { DEBUG_PRINT_KEY(); return false; }

                TPJSON val(GetPointer(this), jtUNDEF);
                TPJSON *oc = Add(val);  // object type not yet defined
                oc.key = l_key; l_key = "";  // set name of key
                i++; if (!oc.Deserialize(json, len, i)) { DEBUG_PRINT_KEY(); return false; }
                break;
            }

            // delimiter; the value type must already be defined
            case ',': {
                i0 = i+1;
                if (!parent && type != jtOBJ) {
                    DEBUG_PRINT_KEY(); return false;
                }
                else if (parent) {
                    if (parent.type != jtARRAY && parent.type != jtOBJ) { DEBUG_PRINT_KEY(); return false; }
                    if (parent.type == jtARRAY && type == jtUNDEF) return true;
                }
                break;
            }

            // - primitives can ONLY be in an array / or on their own -
            // beginning of the object. Create an object and fetch it from json
            case '{': {
                i0 = i+1;
                if (type != jtUNDEF) { DEBUG_PRINT_KEY(); return false; }  // type error
                type = jtOBJ;  // set the value type
                i++; if (!Deserialize(json, len, i)) { DEBUG_PRINT_KEY(); return false; }  // pull it out
                if (i >= len) return false;
                return json[i] == '}' || json[i] == 0;
                break;
            }

            // end of object, current value must be object
            case '}': return type == jtOBJ;

            // beginning of 'true' or 'false'
            case 't': case 'T':
            case 'f': case 'F': {
                if (type != jtUNDEF) { DEBUG_PRINT_KEY(); return false; }  // type error
                type = jtBOOL;  // set the value type
                if (i+3 < len) { if (StringCompare(GetStr(json, i, 4), "true", false) == 0) { bool_v=true; i += 3; return true; } }
                if (i+4 < len) { if (StringCompare(GetStr(json, i, 5), "false", false) == 0) { bool_v=false; i += 4; return true; } }
                DEBUG_PRINT_KEY(); return false;  // wrong type or end of line
                break;
            }

            // beginning of null
            case 'n': case 'N': {
                if (type != jtUNDEF) { DEBUG_PRINT_KEY(); return false; }  // type error
                type = jtNULL;  // set the value type
                if (i+3 < len) if (StringCompare(GetStr(json, i, 4), "null", false) == 0) { i += 3; return true; }
                DEBUG_PRINT_KEY(); return false;  // not NULL or end of line
                break;
            }

            // beginning of number
            case '0': case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '-': case '+': case '.': {
                if (type != jtUNDEF) { DEBUG_PRINT_KEY(); return false; }  // type error

                bool dbl = false;  // set the value type
                int is = i;
                while (json[i] != 0 && i < len) {
                    i++;
                    if (StringFind(num, GetStr(json, i, 1)) < 0) break;
                    if (!dbl) dbl = (json[i] == '.' || json[i] == 'e' || json[i] == 'E');
                }
                str_v = GetStr(json, is, i-is);
                if (dbl) { type = jtDBL; dbl_v = StringToDouble(str_v); int_v = (long)dbl_v; bool_v = int_v != 0; }
                else { type = jtINT; int_v = StringToInteger(str_v); dbl_v = (double)int_v; bool_v = int_v != 0; }  // clarified the value type

                i--;

                return true;  // moved 1 character back and exited
            }

            // start or end of line
            case '\"': {
                // if the type has not yet been defined and the key has not been set
                if (type == jtOBJ) {
                    i++; int is = i;
                    if (!ExtrStr(json, len, i)) { DEBUG_PRINT_KEY(); return false; }  // this is the key, go to the end of the line

                    l_key = GetStr(json, is, i-is);
                }
                else {
                    if (type != jtUNDEF) { DEBUG_PRINT_KEY(); return false; }  // type error

                    type = jtSTR;  // set the value type
                    i++; int is = i;
                    if (!ExtrStr(json, len, i)) { DEBUG_PRINT_KEY(); return false; }
                    FromStr(jtSTR, GetStr(json, is, i-is));
                    return true;
                }

                break;
            }
		}
	}

	return true;
}

//------------------------------------------------------------------	ExtrStr
bool TPJSON::ExtrStr(char& json[], int len, int &i) {
	for (; json[i] != 0 && i<len; i++) {
		char c = json[i];

		if (c == '\"') break;  // end of line

		if (c == '\\' && i+1 < len) {
			i++; c = json[i];
			switch (c) {
			    // it is allowed
                case '/': case '\\': case '\"': case 'b': case 'f': case 'r': case 'n': case 't': break;

                // \uXXXX
                case 'u': {
                    i++;
                    for (int j=0; j<4 && i<len && json[i] != 0; j++, i++) {
                        // not hex
                        if (!((json[i] >= '0' && json[i] <= '9') || (json[i] >= 'A' && json[i] <= 'F') || (json[i] >= 'a' && json[i] <= 'f'))) {
                            Print(key+" "+CharToString(json[i])+" "+string(__LINE__));
                            return false;
                        }
                    }
                    i--;
                    break;
                }

                default: break; /*{ return false; } // not allowed escaped character */
			}
		}
	}
	return true;
}

//------------------------------------------------------------------	Escape
string TPJSON::Escape(string v) {
	ushort as[], s[];
	int n = StringToShortArray(v, as);

	if (ArrayResize(s, 2*n) != 2*n) return NULL;

	int j = 0;
	for (int i=0; i<n; i++) {
		switch (as[i]) {
            case '\\': s[j] = '\\'; j++; s[j] = '\\'; j++; break;
            case '"': s[j] = '\\'; j++; s[j] = '"'; j++; break;
            case '/': s[j] = '\\'; j++; s[j] = '/'; j++; break;
            case 8: s[j] = '\\'; j++; s[j] = 'b'; j++; break;
            case 12: s[j] = '\\'; j++; s[j] = 'f'; j++; break;
            case '\n': s[j] = '\\'; j++; s[j] = 'n'; j++; break;
            case '\r': s[j] = '\\'; j++; s[j] = 'r'; j++; break;
            case '\t': s[j] = '\\'; j++; s[j] = 't'; j++; break;
            default: s[j] = as[i]; j++; break;
		}
	}

	return ShortArrayToString(s, 0, j);
}

//------------------------------------------------------------------	Unescape
string TPJSON::Unescape(string v) {
	ushort as[], s[];
	int n = StringToShortArray(v, as);

	if (ArrayResize(s, n) != n) return NULL;

	int j = 0, i = 0;
	while (i < n) {
		ushort c = as[i];
		if (c == '\\' && i < n-1) {
			switch (as[i+1]) {
                case '\\': c = '\\'; i++; break;
                case '"': c = '"'; i++; break;
                case '/': c = '/'; i++; break;
                case 'b': c = 8; /*08 = '\b'*/; i++; break;
                case 'f': c = 12;/*0c = \f*/ i++; break;
                case 'n': c = '\n'; i++; break;
                case 'r': c = '\r'; i++; break;
                case 't': c = '\t'; i++; break;

                // \uXXXX
                case 'u': {
                    i += 2; ushort k = 0;
                    for (int jj=0; jj<4 && i<n; jj++, i++) {
                        c = as[i]; ushort h = 0;

                        if (c >= '0' && c <= '9') h = c-'0';
                        else if (c >= 'A' && c <= 'F') h = c-'A'+10;
                        else if (c >= 'a' && c <= 'f') h = c-'a'+10;
                        else break; // not hex

                        k += h * (ushort)pow(16, (3 - jj));
                    }
                    i--;
                    c = k;
                    break;
                }
			}
		}
		s[j] = c; j++; i++;
	}

	return ShortArrayToString(s, 0, j);
}