package box2D.collision;


import box2D.common.math.B2Vec2;

	
/**
 * The broad-phase is used for computing pairs and performing volume queries and ray casts.
 * This broad-phase does not persist pairs. Instead, this reports potentially new pairs.
 * It is up to the client to consume the new pairs and to track subsequent overlap.
 */
class B2DynamicTreeBroadPhase implements IBroadPhase
{
	/**
	 * Create a proxy with an initial AABB. Pairs are not reported until
	 * UpdatePairs is called.
	 */
	public function createProxy(aabb:B2AABB, userData:Dynamic):Dynamic
	{
		var proxy:B2DynamicTreeNode = m_tree.createProxy(aabb, userData);
		++m_proxyCount;
		bufferMove(proxy);
		return proxy;
	}
	
	/**
	 * Destroy a proxy. It is up to the client to remove any pairs.
	 */
	public function destroyProxy(proxy:Dynamic):Void
	{
		unBufferMove(proxy);
		--m_proxyCount;
		m_tree.destroyProxy(proxy);
	}
	
	/**
	 * Call MoveProxy as many times as you like, then when you are done
	 * call UpdatePairs to finalized the proxy pairs (for your time step).
	 */
	public function moveProxy(proxy:Dynamic, aabb:B2AABB, displacement:B2Vec2):Void
	{
		var buffer:Bool = m_tree.moveProxy(proxy, aabb, displacement);
		if (buffer)
		{
			bufferMove(proxy);
		}
	}
	
	public function testOverlap(proxyA:Dynamic, proxyB:Dynamic):Bool
	{
		var aabbA:B2AABB = m_tree.getFatAABB(proxyA);
		var aabbB:B2AABB = m_tree.getFatAABB(proxyB);
		return aabbA.testOverlap(aabbB);
	}
	
	/**
	 * Get user data from a proxy. Returns null if the proxy is invalid.
	 */
	public function getUserData(proxy:Dynamic):Dynamic
	{
		return m_tree.getUserData(proxy);
	}
	
	/**
	 * Get the AABB for a proxy.
	 */
	public function getFatAABB(proxy:Dynamic):B2AABB
	{
		return m_tree.getFatAABB(proxy);
	}
	
	/**
	 * Get the number of proxies.
	 */
	public function getProxyCount():Int
	{
		return m_proxyCount;
	}
	
	/**
	 * Update the pairs. This results in pair callbacks. This can only add pairs.
	 */
	public function updatePairs(callbackMethod:Dynamic):Void
	{
		m_pairCount = 0;
		// Perform tree queries for all moving queries
		for (queryProxy in m_moveBuffer)
		{
			function queryCallback(proxy:B2DynamicTreeNode):Bool
			{
				// A proxy cannot form a pair with itself.
				if (proxy == queryProxy)
					return true;
					
				// Grow the pair buffer as needed
				if (m_pairCount == m_pairBuffer.length)
				{
					m_pairBuffer[m_pairCount] = new B2DynamicTreePair();
				}
				
				var pair:B2DynamicTreePair = m_pairBuffer[m_pairCount];
				
				if (proxy.id < queryProxy.id) {
					
					pair.proxyA = proxy;
					pair.proxyB = queryProxy;
					
				} else {
					
					pair.proxyA = queryProxy;
					pair.proxyB = proxy;
					
				}
				//pair.proxyA = proxy < queryProxy?proxy:queryProxy;
				//pair.proxyB = proxy >= queryProxy?proxy:queryProxy;
				++m_pairCount;
				
				return true;
			}
			// We have to query the tree with the fat AABB so that
			// we don't fail to create a pair that may touch later.
			var fatAABB:B2AABB = m_tree.getFatAABB(queryProxy);
			m_tree.query(queryCallback, fatAABB);
		}
		
		// Reset move buffer
		m_moveBuffer = new Array <B2DynamicTreeNode> ();
		//m_moveBuffer.length = 0;
		
		// Sort the pair buffer to expose duplicates.
		// TODO: Something more sensible
		//m_pairBuffer.sort(ComparePairs);
		
		// Send the pair buffer
		//for (i in 0...m_pairCount)
		var pairing = true;
		var i = 0;
		while (pairing)
		{
			if (i >= m_pairCount) {
				
				pairing = false;
				
			} else {
				
				var primaryPair:B2DynamicTreePair = m_pairBuffer[i];
				var userDataA:Dynamic = m_tree.getUserData(primaryPair.proxyA);
				var userDataB:Dynamic = m_tree.getUserData(primaryPair.proxyB);
				callbackMethod(userDataA, userDataB);
				++i;
				
				// Skip any duplicate pairs
				while (i < m_pairCount)
				{
					var pair:B2DynamicTreePair = m_pairBuffer[i];
					if (pair.proxyA != primaryPair.proxyA || pair.proxyB != primaryPair.proxyB)
					{
						break;
					}
					++i;
				}
				
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function query(callbackMethod:Dynamic -> Bool, aabb:B2AABB):Void
	{
		m_tree.query(callbackMethod, aabb);
	}
	
	/**
	 * @inheritDoc
	 */
	public function rayCast(callbackMethod:B2RayCastInput -> Dynamic -> Float, input:B2RayCastInput):Void
	{
		m_tree.rayCast(callbackMethod, input);
	}
	
	
	public function validate():Void
	{
		//TODO_BORIS
	}
	
	public function rebalance(iterations:Int):Void
	{
		m_tree.rebalance(iterations);
	}
	
	
	// Private ///////////////
	
	private function bufferMove(proxy:B2DynamicTreeNode):Void
	{
		m_moveBuffer[m_moveBuffer.length] = proxy;
	}
	
	private function unBufferMove(proxy:B2DynamicTreeNode):Void
	{
		m_moveBuffer.remove (proxy);
	}
	
	private function comparePairs(pair1:B2DynamicTreePair, pair2:B2DynamicTreePair):Int
	{
		//TODO_BORIS:
		// We cannot consistently sort objects easily in AS3
		// The caller of this needs replacing with a different method.
		return 0;
	}
	
	public function new () {
		
		m_tree = new B2DynamicTree();
		m_moveBuffer = new Array <B2DynamicTreeNode>();
		
		m_pairBuffer = new Array <B2DynamicTreePair>();
		m_pairCount = 0;
		
	}
	
	private var m_tree:B2DynamicTree;
	private var m_proxyCount:Int;
	private var m_moveBuffer:Array <B2DynamicTreeNode>;
	
	private var m_pairBuffer:Array <B2DynamicTreePair>;
	private var m_pairCount:Int;
}