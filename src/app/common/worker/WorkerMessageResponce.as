package app.common.worker
{
	public final class WorkerMessageResponce
	{
		private var _responce:*;
		private var _pipeID:uint;

		public function WorkerMessageResponce(responce:*, pipeID:uint)
		{
			this._responce = responce;
			this._pipeID = pipeID;
		}

		public function get responce():* { return _responce; }
		public function get pipeID():uint { return _pipeID; }

	}
}