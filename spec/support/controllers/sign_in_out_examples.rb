# Examples related to sign in/out process for controller specs, like sign in required and so on.

shared_examples 'controller sign in required' do
  describe 'when user not signed in' do
    it 'should redirect to sign in action with error flash' do
      expect(response).to redirect_to(sign_in_url)
      expect(flash[:error]).not_to be_nil
    end
  end
end
