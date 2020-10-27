package common;

class ArrayTools {
	macro public static function mapSum<A, B>(array:ExprOf<Array<A>>, f:ExprOf<A->B>):ExprOf<Maybe<B>> {
		return macro {
			var array = $array;
			var f = $f;
			var res = null;
			for (e in array)
				if (res == null)
					res = f(e);
				else
					res = res + f(e);
			common.Maybe.of(res);
		}
	}

	macro public static function mapMax<A, B>(array:ExprOf<Array<A>>, f:ExprOf<A->B>):ExprOf<Maybe<B>> {
		return macro {
			var array = $array;
			var f = $f;
			var res = null;
			for (e in array)
				if (res == null)
					res = f(e);
				else
					res = res.max(f(e));
			common.Maybe.of(res);
		}
	}

	macro public static function mapMin<A, B>(array:ExprOf<Array<A>>, f:ExprOf<A->B>):ExprOf<Maybe<B>> {
		return macro {
			var array = $array;
			var f = $f;
			var res = null;
			for (e in array)
				if (res == null)
					res = f(e);
				else
					res = res.min(f(e));
			common.Maybe.of(res);
		}
	}
}
