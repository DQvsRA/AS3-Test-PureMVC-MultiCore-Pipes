package app.common.worker
{
	public final class MessageResponce
	{
		private var _responce:*;
		private var _pipeID:uint;

		public function MessageResponce(responce:*, pipeID:uint)
		{
			this._responce = responce;
			this._pipeID = pipeID;
		}

		public function get responce():* { return _responce; }
		public function get pipeID():uint { return _pipeID; }

	}
}