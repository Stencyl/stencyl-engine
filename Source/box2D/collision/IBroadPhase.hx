package box2D.collision;

import box2D.common.math.B2Vec2;
/**
 * Interface for objects tracking overlap of many AABBs.
 */
interface IBroadPhase 
{
	/**
	 * Create a proxy with an initial AABB. Pairs are not reported until
	 * UpdatePairs is called.
	 */
	function createProxy(aabb:B2AABB, userData:Dynamic):Dynamic;
	
	/**
	 * Destroy a proxy. It is up to the client to remove any pairs.
	 */
	function destroyProxy(proxy:Dynamic):Void;
	
	/**
	 * Call MoveProxy as many times as you like, then when you are done
	 * call UpdatePairs to finalized the proxy pairs (for your time step).
	 */
	function moveProxy(proxy:Dynamic, aabb:B2AABB, displacement:B2Vec2):Void;
	
	function testOverlap(proxyA:Dynamic, proxyB:Dynamic):Bool;
	
	/**
	 * Get user data from a proxy. Returns null if the proxy is invalid.
	 */
	function getUserData(proxy:Dynamic):Dynamic;
	
	/**
	 * Get the fat AABB for a proxy.
	 */
	function getFatAABB(proxy:Dynamic):B2AABB;
	
	/**
	 * Get the number of proxies.
	 */
	function getProxyCount():Int;
	
	/**
	 * Update the pairs. This results in pair callbacks. This can only add pairs.
	 */
	function updatePairs(callbackMethod:Dynamic):Void;
	
	/**
	 * Query an AABB for overlapping proxies. The callback class
	 * is called with each proxy that overlaps 
	 * the supplied AABB, and return a Boolean indicating if 
	 * the broaphase should proceed to the next match.
	 * @param callback This function should be a function matching signature
	 * <code>function Callback(proxy:*):Bool</code>
	 */
	function query(callbackMethod:Dynamic -> Bool, aabb:B2AABB):Void;
	
	/**
	 * Ray-cast  agains the proxies in the tree. This relies on the callback
	 * to perform exact ray-cast in the case where the proxy contains a shape
	 * The callback also performs any collision filtering
	 * @param callback This function should be a function matching signature
	 * <code>function Callback(subInput:B2RayCastInput, proxy:*):Float</code>
	 * Where the returned number is the new value for maxFraction
	 */
	function rayCast(callbackMethod:B2RayCastInput -> Dynamic -> Float, input:B2RayCastInput):Void;
	
	/**
	 * For debugging, throws in invariants have been broken
	 */
	function validate():Void;
	
	/**
	 * Give the broadphase a chance for structural optimizations
	 */
	function rebalance(iterations:Int):Void;
}