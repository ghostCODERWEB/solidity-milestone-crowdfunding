export async function suite(h) {
  const token = await h.token();
  const c = await h.deploy("MilestoneCrowdfund", [
    token.target,
    h.addresses[1],
    (await h.now()) + 20,
    500,
    h.addresses[0],
  ]);
  await h.tx(token.approve(c.target, 1000));
  await h.tx(c.contribute(600));
  await h.test("premature finalization rejected", () =>
    h.revert(() => c.finalizeFunding()),
  );
  await h.test("goal completion marks success", async () => {
    await h.mine(21);
    await h.tx(c.finalizeFunding());
    h.eq(await c.successful(), true);
  });
  await h.test("successful campaign cannot refund", () =>
    h.revert(() => c.refund()),
  );
  await h.test("beneficiary controls milestone proposals", async () => {
    await h.revert(() => c.proposeMilestone(200, 10));
    await h.tx(c.connect(h.signers[1]).proposeMilestone(200, 10));
  });
  await h.test("duplicate approval rejected", async () => {
    await h.tx(c.approveMilestone(1));
    await h.revert(() => c.approveMilestone(1));
  });
  await h.test("approved milestone releases once", async () => {
    await h.mine(11);
    await h.tx(c.release(1));
    h.eq(await token.balanceOf(h.addresses[1]), 200n);
    h.eq(await c.remaining(), 400n);
    await h.revert(() => c.release(1));
  });
}
